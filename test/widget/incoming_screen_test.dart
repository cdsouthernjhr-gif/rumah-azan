import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rumah_azan/core/services/native_bridge.dart';
import 'package:rumah_azan/data/local/database.dart';
import 'package:rumah_azan/data/providers/providers.dart';
import 'package:rumah_azan/data/repositories/audio_repository.dart';
import 'package:rumah_azan/features/incoming/incoming_files_screen.dart';

void main() {
  testWidgets('shared audio replaces an existing azan; links kept, cache cleaned', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    final db = AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    late Directory tmp;
    late int azanId;
    late File shared;
    await tester.runAsync(() async {
      tmp = await Directory.systemTemp.createTemp('ra_w');
      final repo = AudioRepository(db, () async => Directory('${tmp.path}/audio'));
      azanId = await repo.importStream(Stream.value([1]), 'azan_lama.mp3', title: 'Azan Subuh', category: 'azan');
      shared = File('${tmp.path}/cache/123_azan_mekah.mp3')
        ..createSync(recursive: true)
        ..writeAsBytesSync([5, 5, 5]);
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        appDirResolverProvider.overrideWithValue((name) async => Directory('${tmp.path}/$name')),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => IncomingFilesScreen(files: [
                    IncomingFile(name: 'azan_mekah.mp3', kind: 'audio', path: shared.path),
                  ]),
                )),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    Future<void> settle() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.tap(find.text('open'));
    await settle();
    expect(find.text('Fail diterima'), findsOneWidget);
    expect(find.text('azan_mekah.mp3'), findsOneWidget);

    // Choose "Ganti sedia ada" → Save stays disabled until a target is picked.
    await tester.tap(find.text('Ganti sedia ada'));
    await settle();
    final save = find.widgetWithText(FilledButton, 'Simpan');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await settle();
    await tester.tap(find.textContaining('Azan Subuh').last);
    await settle();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);

    await tester.tap(save);
    // Saving does real file + database work: give it time (bounded).
    for (var i = 0; i < 20 && find.text('Fail diterima').evaluate().isNotEmpty; i++) {
      await settle();
    }

    expect(find.text('Fail diterima'), findsNothing, reason: 'screen closes after saving');
    await tester.runAsync(() async {
      final rows = await db.select(db.audioLibrary).get();
      expect(rows.length, 1, reason: 'replaced, not added');
      expect(rows.single.id, azanId);
      expect(rows.single.title, 'Azan Subuh');
      expect(File(rows.single.filePath).readAsBytesSync(), [5, 5, 5]);
      expect(shared.existsSync(), isFalse, reason: 'cached copy deleted');
    });

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await db.close();
      await tmp.delete(recursive: true);
    });
  });
}
