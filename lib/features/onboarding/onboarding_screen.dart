import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../data/providers/providers.dart';
import '../../data/static/jakim_zones.dart';
import '../../shared/widgets/common.dart';
import '../location/zone_picker_screen.dart';

/// First-run setup: language, prayer zone (Kluang/JHR03 pre-selected but must
/// be confirmed) and notification permission.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String _zone = AppConstants.defaultZoneCode;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final zone = zoneByCode(_zone)!;
    final tt = Theme.of(context).textTheme;
    return WallpaperScaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(padding: const EdgeInsets.all(24), shrinkWrap: true, children: [
              Icon(Icons.mosque_rounded, size: 72, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 8),
              Text('Rumah Azan', textAlign: TextAlign.center, style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text(context.tr('tagline'), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.tr('language'), style: tt.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'ms', label: Text('Bahasa Melayu')),
                      ButtonSegment(value: 'en', label: Text('English')),
                    ],
                    selected: {s.language},
                    onSelectionChanged: (v) => ref.read(settingsProvider.notifier).update({'language': v.first}),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.tr('onboard_zone_title'), style: tt.titleSmall),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.place_rounded),
                    title: Text('${zone.code} — ${zone.state}'),
                    subtitle: Text(zone.areas),
                  ),
                  Text(context.tr('onboard_zone_hint'), style: tt.bodySmall),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.search),
                    label: Text(context.tr('choose_other_zone')),
                    onPressed: () async {
                      final code = await push<String>(context, const ZonePickerScreen(returnOnly: true));
                      if (code != null) setState(() => _zone = code);
                    },
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.tr('onboard_notif_title'), style: tt.titleSmall),
                  const SizedBox(height: 4),
                  Text(context.tr('onboard_notif_body'), style: tt.bodySmall),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(context.tr('allow_notifications')),
                    onPressed: () => ref.read(nativeBridgeProvider).requestNotificationPermission(),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                autofocus: true,
                icon: const Icon(Icons.check_rounded),
                label: Text(context.tr('confirm_zone_start', {'z': zone.code})),
                onPressed: () async {
                  await ref.read(settingsProvider.notifier).update({'zoneCode': _zone, 'onboardingDone': true});
                  ref.read(appControllerProvider).refreshPrayerData(force: true);
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
