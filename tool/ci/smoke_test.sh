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
echo "SMOKE TEST PASSED: $PKG running (pid $PID)"
