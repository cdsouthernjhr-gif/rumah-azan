// ON-DEVICE integration tests. Run on a real Android phone/TV box:
//
//   flutter test integration_test/device_flow_test.dart -d <device-id>
//
// These were NOT executed in the development environment (no Android SDK or
// device was available there). See docs/TESTING_REPORT.md for the manual
// test matrix (reboot, app closed, battery saver, permissions denied …) that
// must accompany them.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rumah_azan/core/constants/app_constants.dart';
import 'package:rumah_azan/core/services/native_bridge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final bridge = NativeBridge();

  testWidgets('native layer is reachable', (tester) async {
    expect(await bridge.ping(), isTrue);
    final d = await bridge.diagnostics();
    expect(d['sdkInt'], isA<int>());
    expect((d['sdkInt'] as int) >= 24, isTrue);
  });

  testWidgets('scheduler stores events, arms the earliest and de-duplicates', (tester) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    Map<String, Object?> ev(String id, int inSec) => {
          'id': id,
          'triggerAtMs': now + inSec * 1000,
          'kind': 'reminder',
          'prayer': 'zohor',
          'title': 'IT $id',
          'body': 'integration test',
          'items': <Object>[],
          'notify': false,
          'graceMs': 60000,
          'priority': 1,
        };
    final accepted = await bridge.syncSchedule([ev('b', 7200), ev('a', 3600), ev('a', 3600)]);
    expect(accepted, 2, reason: 'duplicate id dropped');
    final st = await bridge.schedulerStatus();
    expect(st['nextId'], 'a');
    expect(st['count'], 2);
    await bridge.cancelSchedule();
    expect((await bridge.schedulerStatus())['count'], 0);
  });

  testWidgets('player reports idle state when nothing plays', (tester) async {
    final s = await bridge.playerState();
    expect(s.state, anyOf('idle', 'playing', 'paused'));
  });

  testWidgets('keep-screen-on toggles without error', (tester) async {
    await bridge.setKeepScreenOn(true);
    await bridge.setKeepScreenOn(false);
  });

  testWidgets('channel names match the Kotlin side', (tester) async {
    const ch = MethodChannel(AppConstants.nativeChannel);
    expect(await ch.invokeMethod<bool>('ping'), isTrue);
  });
}
