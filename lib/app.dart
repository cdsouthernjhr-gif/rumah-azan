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

class _RumahAzanAppState extends ConsumerState<RumahAzanApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(appControllerProvider).onResume());
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

    // Re-plan alarms when the date rolls over (keeps the 7-day horizon full).
    ref.listen(todayKeyProvider, (prev, next) {
      if (prev != null && prev != next) ref.read(appControllerProvider).resyncSchedule();
    });

    return L10nScope(
      l10n: L10n(s.language),
      child: MaterialApp(
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
