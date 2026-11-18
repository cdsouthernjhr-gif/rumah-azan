import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/services/native_bridge.dart';
import '../../data/repositories/audio_repository.dart';
import '../../data/repositories/misc_repositories.dart';

/// What to do with one shared file.
enum IncomingAction { addNew, replaceExisting, skip }

class IncomingChoice {
  IncomingChoice(this.file)
      : action = file.usable ? IncomingAction.addNew : IncomingAction.skip,
        category = guessAudioCategory(file.name);

  final IncomingFile file;
  IncomingAction action;

  /// Audio category for addNew.
  String category;

  /// Audio/wallpaper id to replace for replaceExisting.
  int? targetId;

  /// Images only: use as the fixed wallpaper right away.
  bool useAsWallpaper = false;
}

/// Sensible default category from the file name (user can change it).
String guessAudioCategory(String name) {
  final n = name.toLowerCase();
  if (RegExp(r'azan|adhan|adzan|athan').hasMatch(n)) return 'azan';
  if (RegExp(r'selawat|salawat|shalawat').hasMatch(n)) return 'selawat';
  if (RegExp(r'zikir|zikr|dhikr|tasbih').hasMatch(n)) return 'zikr';
  if (RegExp(r'doa|dua').hasMatch(n)) return 'doa';
  if (RegExp(r'surah|quran|ayat|yasin|kahf|mulk').hasMatch(n)) return 'quran';
  return 'other';
}

class IncomingResult {
  int added = 0;
  int replaced = 0;
  int skipped = 0;
  final errors = <String>[];
  bool audioChanged = false;

  /// Id of the last new wallpaper marked "use now".
  int? newWallpaperToUse;
}

/// Applies the user's choices. Pure logic over the repositories (testable).
/// Cached copies are always deleted afterwards.
class IncomingFilesProcessor {
  IncomingFilesProcessor({required this.audio, required this.wallpapers});
  final AudioRepository audio;
  final WallpaperRepository wallpapers;

  Future<IncomingResult> apply(List<IncomingChoice> choices) async {
    final r = IncomingResult();
    for (final c in choices) {
      final f = c.file;
      try {
        if (!f.usable || c.action == IncomingAction.skip) {
          r.skipped++;
          continue;
        }
        final data = File(f.path!).openRead();
        final title = p.basenameWithoutExtension(f.name);
        if (f.kind == 'audio') {
          if (c.action == IncomingAction.replaceExisting) {
            if (c.targetId == null) throw StateError('Pilih audio untuk diganti');
            await audio.replaceFile(c.targetId!, data, f.name);
            r.replaced++;
          } else {
            await audio.importStream(data, f.name, title: title, category: c.category);
            r.added++;
          }
          r.audioChanged = true;
        } else {
          if (c.action == IncomingAction.replaceExisting) {
            if (c.targetId == null) throw StateError('Pilih wallpaper untuk diganti');
            await wallpapers.replace(c.targetId!, data, f.name);
            r.replaced++;
          } else {
            final id = await wallpapers.import(data, f.name, title);
            if (c.useAsWallpaper) r.newWallpaperToUse = id;
            r.added++;
          }
        }
      } catch (e) {
        r.errors.add('${f.name}: $e');
      }
    }
    await discard(choices.map((c) => c.file));
    return r;
  }

  /// Deletes the cached copies (also used when the user cancels).
  static Future<void> discard(Iterable<IncomingFile> files) async {
    for (final f in files) {
      if (f.path == null) continue;
      final file = File(f.path!);
      if (await file.exists()) await file.delete();
    }
  }
}
