import 'dart:io';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../../features/audio_scheduler/domain/schedule_planner.dart';
import '../local/database.dart';

const audioCategories = ['azan', 'quran', 'zikr', 'selawat', 'doa', 'other'];

class DownloadProgress {
  const DownloadProgress(this.received, this.total);
  final int received;
  final int? total;
  double? get fraction => total == null || total == 0 ? null : received / total!;
}

class AudioRepository {
  AudioRepository(this.db, this.audioDir, {http.Client? client}) : _client = client ?? http.Client();

  final AppDatabase db;

  /// App-private directory for imported/downloaded audio.
  final Future<Directory> Function() audioDir;
  final http.Client _client;

  static const maxDownloadBytes = 150 * 1024 * 1024;
  static const allowedExt = {'.mp3', '.m4a', '.aac', '.ogg', '.opus', '.wav', '.flac'};

  Stream<List<AudioRow>> watchAll() =>
      (db.select(db.audioLibrary)..orderBy([(t) => OrderingTerm.asc(t.category), (t) => OrderingTerm.asc(t.title)]))
          .watch();

  Future<List<AudioRow>> all() => db.select(db.audioLibrary).get();

  Future<String> _uniqueTarget(String fileName) async {
    final dir = await audioDir();
    if (!await dir.exists()) await dir.create(recursive: true);
    final base = p.basenameWithoutExtension(fileName).replaceAll(RegExp(r'[^\w\-. ]'), '_');
    final ext = p.extension(fileName).toLowerCase();
    var target = p.join(dir.path, '$base$ext');
    var i = 1;
    while (await File(target).exists()) {
      target = p.join(dir.path, '${base}_$i$ext');
      i++;
    }
    return target;
  }

  /// Copies a user-selected file into app storage and registers it.
  Future<int> importFile(String sourcePath, {required String title, required String category, String? licenseNote}) async {
    final ext = p.extension(sourcePath).toLowerCase();
    if (!allowedExt.contains(ext)) {
      throw ArgumentError('Format audio tidak disokong: $ext');
    }
    final target = await _uniqueTarget(p.basename(sourcePath));
    await File(sourcePath).copy(target);
    return db.into(db.audioLibrary).insert(AudioLibraryCompanion.insert(
          title: title,
          category: category,
          filePath: target,
          licenseNote: Value(licenseNote),
        ));
  }

  /// Imports from a byte stream (Android content:// picks have no path).
  Future<int> importStream(Stream<List<int>> data, String fileName,
      {required String title, required String category, String? licenseNote}) async {
    final ext = p.extension(fileName).toLowerCase();
    if (!allowedExt.contains(ext)) {
      throw ArgumentError('Format audio tidak disokong: $ext');
    }
    final target = await _uniqueTarget(fileName);
    final sink = File(target).openWrite();
    try {
      await sink.addStream(data);
    } finally {
      await sink.close();
    }
    return db.into(db.audioLibrary).insert(AudioLibraryCompanion.insert(
          title: title,
          category: category,
          filePath: target,
          licenseNote: Value(licenseNote),
        ));
  }

  /// Downloads an audio file over HTTPS into app storage. Certificate
  /// verification is never disabled.
  Future<int> download(
    Uri uri, {
    required String title,
    required String category,
    String? licenseNote,
    void Function(DownloadProgress)? onProgress,
  }) async {
    if (uri.scheme != 'https') throw ArgumentError('Hanya pautan HTTPS dibenarkan');
    final existing = await (db.select(db.audioLibrary)..where((t) => t.sourceUrl.equals(uri.toString())))
        .getSingleOrNull();
    if (existing != null) return existing.id; // avoid unnecessary re-download

    final req = http.Request('GET', uri)..headers['User-Agent'] = 'RumahAzan/0.1';
    final res = await _client.send(req).timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw HttpException('HTTP ${res.statusCode}');
    final type = res.headers['content-type'] ?? '';
    if (!type.startsWith('audio/') && type != 'application/octet-stream') {
      throw HttpException('Kandungan bukan audio ($type)');
    }
    var name = p.basename(uri.path);
    if (!allowedExt.contains(p.extension(name).toLowerCase())) name = '$name.mp3';
    final target = await _uniqueTarget(name);
    final file = File(target);
    final sink = file.openWrite();
    var received = 0;
    try {
      await for (final chunk in res.stream) {
        received += chunk.length;
        if (received > maxDownloadBytes) throw const HttpException('Fail melebihi had saiz');
        sink.add(chunk);
        onProgress?.call(DownloadProgress(received, res.contentLength));
      }
      await sink.close();
    } catch (_) {
      await sink.close();
      if (await file.exists()) await file.delete();
      rethrow;
    }
    return db.into(db.audioLibrary).insert(AudioLibraryCompanion.insert(
          title: title,
          category: category,
          filePath: target,
          sourceUrl: Value(uri.toString()),
          licenseNote: Value(licenseNote),
        ));
  }

  Future<void> rename(int id, String title, String category) =>
      (db.update(db.audioLibrary)..where((t) => t.id.equals(id)))
          .write(AudioLibraryCompanion(title: Value(title), category: Value(category)));

  Future<void> delete(int id) async {
    final row = await (db.select(db.audioLibrary)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (db.delete(db.audioLibrary)..where((t) => t.id.equals(id))).go();
    final f = File(row.filePath);
    if (await f.exists()) await f.delete();
  }

  /// Fills in missing durations using [probe] (native metadata reader).
  Future<int> backfillDurations(Future<int?> Function(String path) probe) async {
    final rows = await (db.select(db.audioLibrary)..where((t) => t.durationMs.isNull())).get();
    var n = 0;
    for (final r in rows) {
      final ms = await probe(r.filePath);
      if (ms == null || ms <= 0) continue;
      await (db.update(db.audioLibrary)..where((t) => t.id.equals(r.id)))
          .write(AudioLibraryCompanion(durationMs: Value(ms)));
      n++;
    }
    return n;
  }

  // ---- Playlists ----------------------------------------------------------
  Stream<List<PlaylistRow>> watchPlaylists() => db.select(db.audioPlaylists).watch();
  Future<List<PlaylistRow>> playlists() => db.select(db.audioPlaylists).get();
  Future<int> createPlaylist(String name) =>
      db.into(db.audioPlaylists).insert(AudioPlaylistsCompanion.insert(name: name));
  Future<void> renamePlaylist(int id, String name) =>
      (db.update(db.audioPlaylists)..where((t) => t.id.equals(id))).write(AudioPlaylistsCompanion(name: Value(name)));
  Future<void> deletePlaylist(int id) => (db.delete(db.audioPlaylists)..where((t) => t.id.equals(id))).go();

  Future<List<AudioRow>> playlistItems(int playlistId) async {
    final q = db.select(db.audioPlaylistItems).join([
      innerJoin(db.audioLibrary, db.audioLibrary.id.equalsExp(db.audioPlaylistItems.audioId)),
    ])
      ..where(db.audioPlaylistItems.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(db.audioPlaylistItems.position)]);
    return (await q.get()).map((r) => r.readTable(db.audioLibrary)).toList();
  }

  Future<void> setPlaylistItems(int playlistId, List<int> audioIds) => db.transaction(() async {
        await (db.delete(db.audioPlaylistItems)..where((t) => t.playlistId.equals(playlistId))).go();
        for (var i = 0; i < audioIds.length; i++) {
          await db.into(db.audioPlaylistItems).insert(AudioPlaylistItemsCompanion.insert(
                playlistId: playlistId,
                audioId: audioIds[i],
                position: i,
              ));
        }
      });

  /// Maps for the schedule planner (only files that still exist on disk).
  Future<(Map<int, AudioRef>, Map<int, List<AudioRef>>)> plannerMaps() async {
    final audio = <int, AudioRef>{};
    for (final r in await all()) {
      if (await File(r.filePath).exists()) audio[r.id] = AudioRef(path: r.filePath, title: r.title);
    }
    final lists = <int, List<AudioRef>>{};
    for (final pl in await playlists()) {
      lists[pl.id] = [
        for (final r in await playlistItems(pl.id))
          if (audio.containsKey(r.id)) audio[r.id]!,
      ];
    }
    return (audio, lists);
  }

  // ---- Playback history ---------------------------------------------------
  Future<void> addHistory(List<Map<String, Object?>> entries) async {
    await db.batch((b) {
      for (final e in entries) {
        final ms = (e['at'] as num?)?.toInt();
        if (ms == null) continue;
        b.insert(
          db.audioPlaybackHistory,
          AudioPlaybackHistoryCompanion.insert(
            eventId: Value(e['eventId'] as String?),
            title: '${e['title'] ?? '-'}',
            status: '${e['status'] ?? 'played'}',
            detail: Value(e['detail'] as String?),
            startedAt: DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<List<PlaybackHistoryRow>> history([int limit = 50]) => (db.select(db.audioPlaybackHistory)
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
        ..limit(limit))
      .get();
}
