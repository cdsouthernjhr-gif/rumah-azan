import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/core/services/native_bridge.dart';
import 'package:rumah_azan/data/local/database.dart';
import 'package:rumah_azan/data/repositories/audio_repository.dart';
import 'package:rumah_azan/data/repositories/misc_repositories.dart';
import 'package:rumah_azan/features/incoming/incoming_files.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  late AudioRepository audio;
  late WallpaperRepository walls;

  File cached(String name, [List<int> bytes = const [1, 2, 3]]) =>
      File('${tmp.path}/cache/${DateTime.now().microsecondsSinceEpoch}_$name')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);

  setUp(() async {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    tmp = await Directory.systemTemp.createTemp('ra_in');
    audio = AudioRepository(db, () async => Directory('${tmp.path}/audio'));
    walls = WallpaperRepository(db, () async => Directory('${tmp.path}/wp'));
  });
  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  test('replacing audio keeps id, title, playlists; swaps the file; old file deleted', () async {
    final id = await audio.importStream(Stream.value([1, 1]), 'azan_lama.mp3', title: 'Azan Subuh', category: 'azan');
    final oldPath = (await audio.byId(id))!.filePath;
    await (db.update(db.audioLibrary)..where((t) => t.id.equals(id)))
        .write(const AudioLibraryCompanion(durationMs: Value(1000)));
    final pl = await audio.createPlaylist('Subuh');
    await audio.setPlaylistItems(pl, [id]);

    final newPath = await audio.replaceFile(id, Stream.value([9, 9, 9, 9]), 'azan_baru.m4a');

    final row = (await audio.byId(id))!;
    expect(row.id, id);
    expect(row.title, 'Azan Subuh');
    expect(row.category, 'azan');
    expect(row.filePath, newPath);
    expect(row.durationMs, isNull, reason: 'duration re-read for the new file');
    expect(File(newPath).readAsBytesSync(), [9, 9, 9, 9]);
    expect(File(oldPath).existsSync(), isFalse);
    expect((await audio.playlistItems(pl)).single.id, id);
    // Planner maps now point at the new file.
    final (refs, lists) = await audio.plannerMaps();
    expect(refs[id]!.path, newPath);
    expect(lists[pl]!.single.path, newPath);
  });

  test('replace rejects unsupported formats and keeps the original', () async {
    final id = await audio.importStream(Stream.value([1]), 'a.mp3', title: 'A', category: 'quran');
    final before = (await audio.byId(id))!.filePath;
    expect(() => audio.replaceFile(id, Stream.value([2]), 'virus.exe'), throwsArgumentError);
    expect((await audio.byId(id))!.filePath, before);
    expect(File(before).existsSync(), isTrue);
  });

  test('replacing a wallpaper keeps its id and deletes the old image', () async {
    final id = await walls.import(Stream.value([1]), 'masjid.jpg', 'Masjid');
    final old = (await walls.byId(id))!.filePath;
    await walls.replace(id, Stream.value([2, 2]), 'masjid_baru.png');
    final row = (await walls.byId(id))!;
    expect(row.id, id);
    expect(row.name, 'Masjid');
    expect(row.filePath, isNot(old));
    expect(row.filePath.endsWith('.png'), isTrue);
    expect(File(old).existsSync(), isFalse);
  });

  test('processor: add, replace, skip, reject — and always cleans the cache', () async {
    final existing = await audio.importStream(Stream.value([1]), 'old.mp3', title: 'Azan', category: 'azan');
    final wpId = await walls.import(Stream.value([1]), 'a.jpg', 'A');

    final fNewAudio = cached('Surah Yasin.mp3');
    final fReplaceAudio = cached('azan_mekah.mp3', [7, 7]);
    final fNewImage = cached('kaabah.jpg');
    final fReplaceImage = cached('baru.webp');
    final fSkip = cached('skip.mp3');

    final choices = [
      IncomingChoice(IncomingFile(name: 'Surah Yasin.mp3', kind: 'audio', path: fNewAudio.path)),
      IncomingChoice(IncomingFile(name: 'azan_mekah.mp3', kind: 'audio', path: fReplaceAudio.path))
        ..action = IncomingAction.replaceExisting
        ..targetId = existing,
      IncomingChoice(IncomingFile(name: 'kaabah.jpg', kind: 'image', path: fNewImage.path))..useAsWallpaper = true,
      IncomingChoice(IncomingFile(name: 'baru.webp', kind: 'image', path: fReplaceImage.path))
        ..action = IncomingAction.replaceExisting
        ..targetId = wpId,
      IncomingChoice(IncomingFile(name: 'skip.mp3', kind: 'audio', path: fSkip.path))..action = IncomingAction.skip,
      IncomingChoice(const IncomingFile(name: 'doc.pdf', kind: 'other', error: 'unsupported')),
    ];
    expect(choices[0].category, 'quran', reason: 'guessed from file name');
    expect(choices.last.action, IncomingAction.skip, reason: 'unusable files default to skip');

    final r = await IncomingFilesProcessor(audio: audio, wallpapers: walls).apply(choices);
    expect(r.added, 2);
    expect(r.replaced, 2);
    expect(r.skipped, 2);
    expect(r.errors, isEmpty);
    expect(r.audioChanged, isTrue);
    expect(r.newWallpaperToUse, isNotNull);
    expect(File((await audio.byId(existing))!.filePath).readAsBytesSync(), [7, 7]);
    expect((await audio.all()).length, 2);
    for (final f in [fNewAudio, fReplaceAudio, fNewImage, fReplaceImage, fSkip]) {
      expect(f.existsSync(), isFalse, reason: 'cached copy removed: ${f.path}');
    }
  });

  test('processor reports a missing replace target instead of failing silently', () async {
    final f = cached('x.mp3');
    final r = await IncomingFilesProcessor(audio: audio, wallpapers: walls).apply([
      IncomingChoice(IncomingFile(name: 'x.mp3', kind: 'audio', path: f.path))..action = IncomingAction.replaceExisting,
    ]);
    expect(r.errors.single, contains('x.mp3'));
    expect(f.existsSync(), isFalse);
  });

  test('category guessing', () {
    expect(guessAudioCategory('Azan Subuh Mekah.mp3'), 'azan');
    expect(guessAudioCategory('selawat_syifa.m4a'), 'selawat');
    expect(guessAudioCategory('Zikir pagi.mp3'), 'zikr');
    expect(guessAudioCategory('doa makan.ogg'), 'doa');
    expect(guessAudioCategory('Surah Al-Kahf.mp3'), 'quran');
    expect(guessAudioCategory('rakaman.wav'), 'other');
  });

  test('IncomingFile parses the native map and flags rejected files', () {
    final ok = IncomingFile.fromMap({'path': '/c/a.mp3', 'name': 'a.mp3', 'kind': 'audio', 'mime': 'audio/mpeg'});
    expect(ok.usable, isTrue);
    final bad = IncomingFile.fromMap({'name': 'a.pdf', 'kind': 'other', 'error': 'unsupported'});
    expect(bad.usable, isFalse);
  });
}
