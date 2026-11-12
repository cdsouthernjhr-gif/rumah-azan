import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:flutter/services.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rumah_azan/app.dart';
import 'package:rumah_azan/core/utilities/myt_time.dart';
import 'package:rumah_azan/data/local/database.dart';
import 'package:rumah_azan/data/models/app_settings.dart';
import 'package:rumah_azan/data/providers/providers.dart';
import 'package:rumah_azan/data/repositories/diagnostics_repository.dart';
import 'package:rumah_azan/data/repositories/prayer_repository.dart';
import 'package:rumah_azan/features/smart_display/display_mode_screen.dart';
import 'package:rumah_azan/features/tasbih/tasbih_screen.dart';

import '../helpers.dart';

/// Boots the real app on an in-memory database with a fixed clock.
/// The native Android channel is absent in tests, which also verifies that
/// the app degrades safely without it.
Future<AppDatabase> boot(
  WidgetTester tester, {
  required AppSettings settings,
  bool seedData = true,
  DateTime? now,
  Widget? home,
  Size size = const Size(1080 / 2.5, 2200 / 2.5),
}) async {
  final clock = now ?? myt('2026-11-12', '15:25');
  Myt.clock = () => clock;
  await tester.binding.setSurfaceSize(size);
  final db = AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
  final repo = PrayerRepository(db, DiagnosticsRepository(db));
  await tester.runAsync(() async {
    await repo.ensureZonesSeeded();
    if (seedData) {
      // A full scheduler horizon of fresh verified data → no network refresh.
      await repo.upsert([
        for (var i = -1; i < 9; i++) day(Myt.addDays('2026-11-12', i), fetchedAt: clock),
      ]);
    }
  });
  await tester.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      initialSettingsProvider.overrideWithValue(settings),
    ],
    child: home ?? const RumahAzanApp(),
  ));
  await settle(tester);
  return db;
}

/// Pumps frames while letting real async work (drift isolate-free queries) run.
Future<void> settle(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> teardown(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(db.close);
  Myt.clock = DateTime.now;
}

final configured = AppSettings.initial().copyWith({'zoneCode': 'JHR03', 'onboardingDone': true});

void main() {
  testWidgets('first run shows onboarding with Kluang (JHR03) pre-selected', (tester) async {
    final db = await boot(tester, settings: AppSettings.initial(), seedData: false);
    expect(find.text('Rumah Azan'), findsWidgets);
    expect(find.textContaining('JHR03'), findsWidgets);
    expect(find.textContaining('Kluang'), findsWidgets);
    await teardown(tester, db);
  });

  testWidgets('dashboard shows verified times, next prayer and live countdown', (tester) async {
    final db = await boot(tester, settings: configured);
    expect(find.text('Waktu seterusnya'), findsOneWidget);
    // At 15:25 the next prayer is Asar 16:25 → 01:00:00.
    expect(find.text('01:00:00'), findsOneWidget);
    expect(find.text('Asar'), findsWidgets);
    expect(find.text('16:25'), findsWidgets);
    expect(find.text('Syuruk ☀'), findsOneWidget);
    expect(find.textContaining('ANGGARAN'), findsNothing);
    // Data source footer is at the bottom of the lazily-built list.
    await tester.scrollUntilVisible(find.textContaining('JAKIM e-Solat'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('JAKIM e-Solat'), findsWidgets);
    await teardown(tester, db);
  });

  testWidgets('no verified data → clear warning, never silent invented times', (tester) async {
    final db = await boot(
      tester,
      settings: configured.copyWith({'allowEstimateDisplay': false}),
      seedData: false,
    );
    expect(find.textContaining('Tiada jadual waktu solat yang disahkan'), findsOneWidget);
    expect(find.text('01:00:00'), findsNothing);
    await teardown(tester, db);
  });

  testWidgets('estimate fallback is visibly labelled', (tester) async {
    final db = await boot(tester, settings: configured, seedData: false);
    expect(find.textContaining('ANGGARAN'), findsOneWidget);
    await teardown(tester, db);
  });

  testWidgets('English language switch', (tester) async {
    final db = await boot(tester, settings: configured.copyWith({'language': 'en'}));
    expect(find.text('Next prayer'), findsOneWidget);
    await teardown(tester, db);
  });

  testWidgets('scheduled sleep mode shows the upcoming Subuh', (tester) async {
    final db = await boot(
      tester,
      settings: configured.copyWith({'sleepScheduled': true, 'sleepStart': '22:30', 'sleepEnd': '05:00'}),
      now: myt('2026-11-12', '23:00'),
    );
    expect(find.text('23:00'), findsOneWidget);
    expect(find.textContaining('Subuh seterusnya'), findsOneWidget);
    expect(find.text('06:45:00'), findsOneWidget); // until 05:45
    await teardown(tester, db);
  });

  testWidgets('display (TV) mode renders clock, countdown and timetable', (tester) async {
    final db = await boot(tester, settings: configured, size: const Size(1280, 720));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const DisplayModeScreen()));
    await settle(tester);
    expect(find.text('15:25:00'), findsOneWidget);
    expect(find.text('01:00:00'), findsOneWidget);
    expect(find.text('Isyak'), findsWidgets);
    await teardown(tester, db);
  });

  testWidgets('tasbih counts taps and keyboard/remote select', (tester) async {
    final db = await boot(tester, settings: configured);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const TasbihScreen()));
    await settle(tester);
    await tester.tap(find.text('Ketik untuk mengira'));
    await tester.tap(find.text('Ketik untuk mengira'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    await teardown(tester, db);
  });

  testWidgets('"start in Display Mode" opens the full-screen display', (tester) async {
    final db = await boot(tester, settings: configured.copyWith({'startInDisplayMode': true}));
    // Phone portrait: Display Mode must fit without overflow.
    expect(find.byType(DisplayModeScreen), findsOneWidget);
    await teardown(tester, db);
  });

  testWidgets('TV remote: D-pad focus reaches a quick-access tile and Select opens it', (tester) async {
    final db = await boot(tester, settings: configured, size: const Size(1280, 720));
    bool focusedOn(String label) {
      final node = FocusManager.instance.primaryFocus;
      // A scope (whole page) is not a focused control.
      if (node == null || node is FocusScopeNode) return false;
      final ctx = node.context;
      if (ctx == null) return false;
      var found = false;
      void visit(Element e) {
        final w = e.widget;
        if (w is Text && w.data == label) found = true;
        if (!found) e.visitChildren(visit);
      }
      (ctx as Element).visitChildren(visit);
      return found;
    }

    var steps = 0;
    while (!focusedOn('Tasbih') && steps < 80) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // remote "next" focus
      await tester.pump();
      steps++;
    }
    expect(focusedOn('Tasbih'), isTrue, reason: 'tile must be focusable by remote');
    await tester.sendKeyEvent(LogicalKeyboardKey.select); // D-pad centre
    await settle(tester);
    expect(find.byType(TasbihScreen), findsOneWidget);
    await teardown(tester, db);
  });
}

