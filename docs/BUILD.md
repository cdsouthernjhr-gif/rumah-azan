# Installation & build

## Easiest: let GitHub build it

Every push runs `.github/workflows/build-apk.yml` (analyze → test → debug APK).
Open the repository on GitHub → **Actions** → **Bina APK** → latest run →
**Artifacts** → `rumah-azan-debug-apk`. Unzip it to get `app-debug.apk`.
You can also start it manually with **Run workflow**.

## Requirements

- Flutter **3.50.x** stable (Dart 3.14). Check with `flutter --version`.
- Android Studio (or command-line tools) with an Android SDK for API 36 and
  JDK 17+. Check with `flutter doctor` (Android toolchain must be ✓).
- A device or emulator running **Android 7.0 (API 24)** or newer.

## Steps

```bash
flutter doctor
```

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

(The generated `lib/data/local/database.g.dart` is committed; regenerate it
only after changing the schema.)

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter build apk --debug
```

Install: `build/app/outputs/flutter-apk/app-debug.apk`
(`adb install -r build/app/outputs/flutter-apk/app-debug.apk`).

## Release build & signing

1. Create a keystore (keep it secret, never commit it):

```bash
keytool -genkey -v -keystore ~/rumah-azan-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias rumahazan
```

2. Create `android/key.properties` (already git-ignored):

```
storeFile=/absolute/path/rumah-azan-release.jks
storePassword=…
keyAlias=rumahazan
keyPassword=…
```

3. Build:

```bash
flutter build apk --release
```

Without `key.properties`, the release build is signed with the **debug key**
and must not be distributed.

## On-device integration tests

```bash
flutter test integration_test/device_flow_test.dart -d <device-id>
```

Note: this test calls `cancelSchedule`; open the app afterwards so the
schedule is re-planned.

## Build status in the development environment

`flutter analyze` and `flutter test` were run successfully. `flutter build apk`
could **not** run there: the Android SDK could not be installed because its
download host (dl.google.com) was blocked. The Kotlin sources were
type-checked separately with Kotlin 2.4.20 against the Android framework
(Robolectric `android-all`) and the Flutter 3.50 embedding jar, with no
errors. A full Gradle/AGP build and lint on a workstation is still required.
