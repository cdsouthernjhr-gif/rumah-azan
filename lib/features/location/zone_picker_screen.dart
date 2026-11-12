import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../data/models/prayer_zone.dart';
import '../../data/providers/providers.dart';
import '../../data/static/jakim_zones.dart';
import '../../shared/widgets/common.dart';

double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1), dLng = rad(lng2 - lng1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(a));
}

/// Nearest non-special zones to a coordinate (suggestions only).
List<(PrayerZone, double)> nearestZones(double lat, double lng, {int count = 3}) {
  final list = [
    for (final z in jakimZones)
      if (!z.special && z.lat != null && z.lng != null) (z, haversineKm(lat, lng, z.lat!, z.lng!)),
  ]..sort((a, b) => a.$2.compareTo(b.$2));
  return list.take(count).toList();
}

class ZonePickerScreen extends ConsumerStatefulWidget {
  const ZonePickerScreen({super.key, this.returnOnly = false});

  /// If true, pops with the selected code instead of saving it.
  final bool returnOnly;

  @override
  ConsumerState<ZonePickerScreen> createState() => _ZonePickerScreenState();
}

class _ZonePickerScreenState extends ConsumerState<ZonePickerScreen> {
  String _query = '';
  String? _state;
  List<(PrayerZone, double)>? _gps;
  bool _locating = false;

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) showSnack(context, context.tr('gps_off'));
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) showSnack(context, context.tr('gps_denied'));
        return;
      }
      // Coarse accuracy is sufficient; the position is used only on-device
      // and is never stored or transmitted.
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.low,
          forceLocationManager: true, // works without Google Play Services
          timeLimit: const Duration(seconds: 30),
        ),
      );
      setState(() => _gps = nearestZones(pos.latitude, pos.longitude));
    } catch (e) {
      if (mounted) showSnack(context, '${context.tr('gps_failed')}: $e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _select(String code) async {
    if (widget.returnOnly) {
      Navigator.pop(context, code);
      return;
    }
    await ref.read(settingsProvider.notifier).update({'zoneCode': code});
    ref.read(dataVersionProvider.notifier).bump();
    ref.read(appControllerProvider).refreshPrayerData(force: true);
    if (mounted) Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(settingsProvider.select((s) => s.zoneCode));
    final zones = jakimZones.where((z) => (_state == null || z.state == _state) && z.matches(_query)).toList();
    return PlainScaffold(
      title: context.tr('choose_zone'),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: context.tr('search_zone_hint'),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(context.tr('all_states')),
                  selected: _state == null,
                  onSelected: (_) => setState(() => _state = null),
                ),
              ),
              for (final s in zoneStates)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(label: Text(s), selected: _state == s, onSelected: (_) => setState(() => _state = s)),
                ),
            ],
          ),
        ),
        ListTile(
          leading: _locating
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location),
          title: Text(context.tr('use_gps')),
          subtitle: Text(context.tr('gps_suggest_note')),
          onTap: _locating ? null : _locate,
        ),
        if (_gps != null)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              for (final (z, km) in _gps!)
                ListTile(
                  title: Text('${z.code} — ${z.state}'),
                  subtitle: Text('${z.areas}\n≈ ${km.toStringAsFixed(0)} km'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _select(z.code),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(context.tr('gps_confirm_note'), style: Theme.of(context).textTheme.bodySmall),
              ),
            ]),
          ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: zones.length,
            itemBuilder: (_, i) {
              final z = zones[i];
              return ListTile(
                selected: z.code == current,
                leading: CircleAvatar(child: Text(z.code.substring(3), style: const TextStyle(fontSize: 12))),
                title: Text('${z.code} · ${z.state}'),
                subtitle: Text(z.areas),
                trailing: z.code == current ? const Icon(Icons.check_circle) : null,
                onTap: () => _select(z.code),
              );
            },
          ),
        ),
      ]),
    );
  }
}
