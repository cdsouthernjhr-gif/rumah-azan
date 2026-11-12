import 'dart:async';

import 'package:flutter/services.dart';

import '../constants/app_constants.dart';

/// State of the single native audio engine (shared by manual playback and
/// scheduled azan/recitation, so the two can never overlap).
class PlayerState {
  const PlayerState({
    this.state = 'idle',
    this.title,
    this.index = 0,
    this.count = 0,
    this.positionMs = 0,
    this.durationMs = 0,
    this.volume = 1.0,
    this.repeatMode = 'off',
    this.shuffle = false,
    this.source = 'manual',
    this.error,
  });

  final String state; // idle | playing | paused
  final String? title;
  final int index;
  final int count;
  final int positionMs;
  final int durationMs;
  final double volume;
  final String repeatMode; // off | one | all
  final bool shuffle;
  final String source; // manual | scheduled
  final String? error;

  bool get isPlaying => state == 'playing';
  bool get isIdle => state == 'idle';

  factory PlayerState.fromMap(Map<Object?, Object?> m) => PlayerState(
        state: m['state'] as String? ?? 'idle',
        title: m['title'] as String?,
        index: (m['index'] as num?)?.toInt() ?? 0,
        count: (m['count'] as num?)?.toInt() ?? 0,
        positionMs: (m['positionMs'] as num?)?.toInt() ?? 0,
        durationMs: (m['durationMs'] as num?)?.toInt() ?? 0,
        volume: (m['volume'] as num?)?.toDouble() ?? 1.0,
        repeatMode: m['repeatMode'] as String? ?? 'off',
        shuffle: m['shuffle'] as bool? ?? false,
        source: m['source'] as String? ?? 'manual',
        error: m['error'] as String?,
      );
}

/// Thin wrapper over the Kotlin platform channel. Every call degrades safely
/// (returns null/false) when the native side is unavailable, e.g. in tests.
class NativeBridge {
  NativeBridge({MethodChannel? channel, EventChannel? events})
      : _ch = channel ?? const MethodChannel(AppConstants.nativeChannel),
        _ev = events ?? const EventChannel(AppConstants.playerEventsChannel);

  final MethodChannel _ch;
  final EventChannel _ev;

  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _ch.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      rethrow;
    }
  }

  Future<Map<String, Object?>> _map(String method, [Object? args]) async {
    final r = await _call<Map<Object?, Object?>>(method, args);
    return r == null ? const {} : r.map((k, v) => MapEntry('$k', v));
  }

  bool _available = true;
  bool get available => _available;

  Future<bool> ping() async {
    try {
      final r = await _ch.invokeMethod<bool>('ping');
      _available = r == true;
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  // ---- Scheduler ----------------------------------------------------------
  /// Replaces the native alarm plan. [options]: respectSilent (bool),
  /// refreshReminderTitle/Body (strings for the "open app to refresh" note).
  Future<int> syncSchedule(List<Map<String, Object?>> events, {Map<String, Object?> options = const {}}) async =>
      (await _call<int>('syncSchedule', {'events': events, 'options': options})) ?? 0;
  Future<void> cancelSchedule() => _call('cancelSchedule');
  Future<Map<String, Object?>> schedulerStatus() => _map('schedulerStatus');
  Future<bool> scheduleTestEvent(int secondsFromNow, String title, String body) async =>
      (await _call<bool>('scheduleTestEvent', {'seconds': secondsFromNow, 'title': title, 'body': body})) ??
      false;
  Future<List<Map<String, Object?>>> drainPlaybackHistory() async {
    final r = await _call<List<Object?>>('drainPlaybackHistory');
    return [
      for (final e in r ?? const [])
        if (e is Map) e.map((k, v) => MapEntry('$k', v)),
    ];
  }

  // ---- Permissions / system ---------------------------------------------
  Future<Map<String, Object?>> diagnostics() => _map('diagnostics');
  Future<bool> requestNotificationPermission() async =>
      (await _call<bool>('requestNotificationPermission')) ?? false;
  Future<void> openExactAlarmSettings() => _call('openExactAlarmSettings');
  Future<void> openBatteryOptimizationSettings() => _call('openBatteryOptimizationSettings');
  Future<void> openNotificationSettings() => _call('openNotificationSettings');
  Future<void> setKeepScreenOn(bool on) => _call('setKeepScreenOn', {'on': on});

  /// Brightness of this app's window only (0..1), or −1 to follow system.
  /// Needs no permission and never changes the system setting.
  Future<void> setWindowBrightness(double value) => _call('setWindowBrightness', {'value': value});

  // ---- Player -------------------------------------------------------------
  Future<void> play({
    required List<Map<String, Object?>> items,
    String? title,
    int startIndex = 0,
    double volume = 1.0,
    String repeatMode = 'off',
    bool shuffle = false,
  }) =>
      _call('play', {
        'items': items,
        'title': title,
        'startIndex': startIndex,
        'volume': volume,
        'repeatMode': repeatMode,
        'shuffle': shuffle,
      });
  Future<void> pause() => _call('pause');
  Future<void> resume() => _call('resume');
  Future<void> stop() => _call('stop');
  Future<void> next() => _call('next');
  Future<void> previous() => _call('previous');
  Future<void> seek(int ms) => _call('seek', {'ms': ms});
  Future<void> setVolume(double v) => _call('setVolume', {'volume': v});
  Future<void> setRepeatMode(String mode) => _call('setRepeatMode', {'mode': mode});
  Future<void> setShuffle(bool on) => _call('setShuffle', {'on': on});
  Future<PlayerState> playerState() async {
    final m = await _call<Map<Object?, Object?>>('playerState');
    return m == null ? const PlayerState() : PlayerState.fromMap(m);
  }

  Stream<PlayerState> playerEvents() => _ev
      .receiveBroadcastStream()
      .where((e) => e is Map)
      .map((e) => PlayerState.fromMap(e as Map<Object?, Object?>))
      .handleError((_) {});
}
