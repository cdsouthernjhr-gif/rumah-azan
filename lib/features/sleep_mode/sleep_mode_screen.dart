import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/native_bridge.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/providers/providers.dart';

/// Minimal, dark night display focused on the upcoming Subuh.
///
/// Brightness is reduced only for this app window (no system setting is
/// changed and no WRITE_SETTINGS permission is needed).
class SleepModeScreen extends ConsumerStatefulWidget {
  const SleepModeScreen({super.key});
  @override
  ConsumerState<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends ConsumerState<SleepModeScreen> {
  late final NativeBridge _bridge;

  @override
  void initState() {
    super.initState();
    _bridge = ref.read(nativeBridgeProvider);
    final s = ref.read(settingsProvider);
    // Window-only brightness: 1.0 − dim (min 5 %).
    _bridge.setWindowBrightness((1 - s.sleepDim).clamp(0.05, 1.0));
    if (s.keepScreenOn) _bridge.setKeepScreenOn(true);
  }

  @override
  void dispose() {
    _bridge.setWindowBrightness(-1); // restore system default
    _bridge.setKeepScreenOn(false);
    super.dispose();
  }

  void _exit() {
    final s = ref.read(settingsProvider);
    final now = Myt.nowInstant();
    ref.read(sleepManualProvider.notifier).set(false);
    if (sleepWindowActive(s, now)) {
      ref.read(sleepDismissedUntilProvider.notifier).set(sleepWindowEnd(s, now));
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(secondTickProvider).value ?? Myt.nowInstant();
    final win = ref.watch(dayWindowProvider).value;
    final dim = ref.watch(settingsProvider.select((s) => s.sleepDim));
    final grey = Colors.white.withValues(alpha: (1 - dim).clamp(0.25, 0.9));

    // Upcoming Subuh: today's if not yet passed, else tomorrow's.
    DateTime? subuh;
    if (win?.today != null && win!.today!.subuh.isAfter(now)) {
      subuh = win.today!.subuh;
    } else if (win?.tomorrow != null) {
      subuh = win!.tomorrow!.subuh;
    }
    final w = Myt.toWall(now);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(children: [
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  '${w.hour.toString().padLeft(2, '0')}:${w.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: grey, fontSize: 96, fontWeight: FontWeight.w200),
                ),
                const SizedBox(height: 24),
                if (subuh != null) ...[
                  Text('${context.tr('upcoming_subuh')} · ${Myt.hhmm(subuh)}', style: TextStyle(color: grey, fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    Myt.countdown(subuh.difference(now)),
                    style: TextStyle(color: grey, fontSize: 40, fontWeight: FontWeight.w300, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ] else
                  Text(context.tr('no_next_prayer'), style: TextStyle(color: grey)),
                if (win?.today != null && !win!.today!.source.isVerified)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(context.tr('estimate_short'), style: TextStyle(color: grey, fontSize: 12)),
                  ),
              ]),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: TextButton.icon(
                autofocus: true,
                icon: Icon(Icons.wb_sunny_outlined, color: grey),
                label: Text(context.tr('exit_sleep'), style: TextStyle(color: grey)),
                onPressed: _exit,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Helper used by quick access: enter sleep mode manually.
void enterSleepMode(WidgetRef ref) => ref.read(sleepManualProvider.notifier).set(true);
