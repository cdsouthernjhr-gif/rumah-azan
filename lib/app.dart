import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/l10n/l10n.dart';
import 'core/services/app_controller.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/providers.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/sleep_mode/sleep_mode_screen.dart';
import 'features/smart_display/display_mode_screen.dart';
import 'features/wallpaper/wallpaper_view.dart';

class RumahAzanApp extends ConsumerStatefulWidget {
  const RumahAzanApp({super.key});

  @override
  ConsumerState<RumahAzanApp> createState() => _RumahAzanAppState();
}

/// Maps the orientation setting to preferred orientations (empty = auto).
List<DeviceOrientation> orientationsFor(String setting) => switch (setting) {
      'portrait' => const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      'landscape' => const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      _ => const [],
    };

class _RumahAzanAppState extends ConsumerState<RumahAzanApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final s = ref.read(settingsProvider);
    SystemChrome.setPreferredOrientations(orientationsFor(s.orientation));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appControllerProvider).onResume();
      // TV box / wall tablet: open straight into the full-screen display.
      final now = ref.read(settingsProvider);
      if (now.startInDisplayMode && now.onboardingDone && now.zoneCode != null && !ref.read(sleepActiveProvider)) {
        _navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const DisplayModeScreen()));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Application resume: re-import native history, refresh data if needed,
    // and recompute the schedule (handles date/time/zone changes meanwhile).
    if (state == AppLifecycleState.resumed) {
      ref.read(appControllerProvider).onResume();
      ref.invalidate(dayWindowProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final sleeping = ref.watch(sleepActiveProvider);
    final slotTheme = s.autoThemeFromSlot ? themeForSlot(ref.watch(activeSlotProvider)) : s.theme;
    final palette = sleeping ? AppPalette.sleep : AppPalette.of(slotTheme);

    ref.listen(settingsProvider.select((s) => s.orientation), (_, next) {
      SystemChrome.setPreferredOrientations(orientationsFor(next));
    });

    // Re-plan alarms when the date rolls over (keeps the planning horizon full).
    ref.listen(todayKeyProvider, (prev, next) {
      if (prev != null && prev != next) ref.read(appControllerProvider).resyncSchedule();
    });

    return L10nScope(
      l10n: L10n(s.language),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Rumah Azan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(palette),
        shortcuts: {
          ...WidgetsApp.defaultShortcuts,
          // Android TV remote: D-pad centre / Enter activates focused item.
          const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
        },
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.linear(s.fontScale)),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: !s.onboardingDone || s.zoneCode == null
            ? const OnboardingScreen()
            : sleeping
                ? const SleepModeScreen()
                : const IdleReturnToDisplay(child: DashboardScreen()),
      ),
    );
  }
}
