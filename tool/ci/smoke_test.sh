#!/usr/bin/env bash
# Installs the debug APK on a running emulator, launches it and verifies the
# app is still alive after 30 s. Prints crash/Flutter logs either way.
set -u
APK="${1:-build/app/outputs/flutter-apk/app-debug.apk}"
PKG=com.rumahazan.app
mkdir -p smoke
adb install -r -g "$APK" || { echo "::error::adb install failed"; exit 1; }
adb logcat -c
adb shell am start -W -n "$PKG/.MainActivity"
sleep 30
PID="$(adb shell pidof "$PKG" | tr -d '\r')"
adb logcat -d > smoke/logcat.txt
adb shell screencap -p /sdcard/smoke.png && adb pull /sdcard/smoke.png smoke/screenshot.png
adb shell dumpsys activity activities | grep -E "mResumedActivity|topResumedActivity" > smoke/activity.txt || true

echo "===== Resumed activity ====="
cat smoke/activity.txt
echo "===== Crashes (AndroidRuntime / FATAL) ====="
grep -A40 -E "FATAL EXCEPTION|AndroidRuntime: " smoke/logcat.txt | head -150 || true
echo "===== Flutter log ====="
grep -E " flutter |Flutter|E/flutter|Unhandled Exception|startup error" smoke/logcat.txt | head -150 || true
echo "===== App process log ====="
if [ -n "$PID" ]; then grep " $PID " smoke/logcat.txt | grep -E " [EW] " | head -100; fi

if [ -z "$PID" ]; then
  echo "::error::App process is not running 30 s after launch (crashed)."
  exit 1
fi
if grep -q "startup error" smoke/logcat.txt; then
  echo "::error::App showed the startup error screen."
  exit 1
fi
echo "Scenario 1 passed: first launch, $PKG running (pid $PID)"

# Scenario 2 (Galaxy S21 report): the background-sync engine and the UI open
# the database at the same time. Close the UI (process stays), force-run the
# job, and immediately relaunch the app.
adb shell input keyevent KEYCODE_BACK
sleep 3
adb logcat -c
adb shell cmd jobscheduler run -f "$PKG" 7301 || echo "(job could not be forced)"
adb shell am start -W -n "$PKG/.MainActivity"
sleep 25
PID2="$(adb shell pidof "$PKG" | tr -d '\r')"
adb logcat -d > smoke/logcat-concurrent.txt
echo "===== Scenario 2: Flutter / crash log ====="
grep -E "startup error|database is locked|FATAL EXCEPTION|E/flutter|Segerak latar" smoke/logcat-concurrent.txt | head -60 || true
if [ -z "$PID2" ]; then echo "::error::Scenario 2: app not running after concurrent start."; exit 1; fi
if grep -qE "startup error|database is locked" smoke/logcat-concurrent.txt; then
  echo "::error::Scenario 2: database error during concurrent start."; exit 1
fi
echo "SMOKE TEST PASSED: both scenarios (pid $PID2)"
