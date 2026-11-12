# Troubleshooting

| Problem | Cause / fix |
|---|---|
| `Target of URI doesn't exist: package:flutter/material.dart` | Run `flutter pub get` **in the project root**; check `flutter --version` is 3.50.x. This project imports `package:material_ui/material_ui.dart` (Material moved out of the framework in Flutter 3.47+). |
| `No Android SDK found` | Install Android Studio / SDK, then `flutter config --android-sdk <path>` and re-run `flutter doctor`. |
| `minSdk` error mentioning API 23 | Flutter 3.50 requires API 24+; Android 6.0 is not supported. |
| "Tiada jadual waktu solat yang disahkan" | No cached JAKIM data: connect to the Internet and press *Kemas kini data sekarang*. Check *Diagnostics → Run self-test → Prayer API connection*. If e-Solat is down, temporarily switch the source to the community mirror. |
| Times differ from the mosque | Check the zone (district alone is not enough). Estimates (orange "ANGGARAN" label) may differ by minutes. |
| Azan does not play when the app is closed | *Diagnostics*: exact alarm ✓, notifications ✓, battery optimisation "exempt". On Xiaomi/Oppo/Vivo/Huawei enable **Autostart** and set the battery policy to **No restrictions**. Use *Test alarm (15 s)*. |
| Azan plays only a notification sound | No azan file is selected: import a licensed azan in category **Azan**, then pick it in *Jadual Audio → Pada waktu solat*. |
| No sound in silent mode | Expected while "Hormati mod senyap & Jangan Ganggu" is on. |
| Recitation didn't play | The playlist is empty, automatic audio is off, Sleep Mode mutes non-essential audio, or the alarm fired more than 5 min late (recorded as *missed*). |
| "Kemas kini jadual Rumah Azan" notification | Fewer than 24 h of scheduled events remain; open the app while online. |
| Compass jumps / "Lemah" | Calibrate (figure 8) away from metal; on TV boxes there is no compass, so use the bearing in degrees. |
| TV remote cannot select | Use D-pad centre/Enter. Report the screen so focus can be fixed. |
| Restore failed | Only Rumah Azan backup files (`"app":"rumah_azan"`) of the same or older format are accepted. |
