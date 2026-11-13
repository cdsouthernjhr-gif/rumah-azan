package com.rumahazan.app

import android.Manifest
import android.app.ActivityManager
import android.app.AlarmManager
import android.app.NotificationManager
import android.app.UiModeManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import com.rumahazan.app.audio.PlaybackService
import com.rumahazan.app.scheduler.Scheduler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {

    companion object {
        /** True while the UI activity exists (BackgroundSyncJob skips then). */
        @Volatile
        var isRunning = false

        private const val CHANNEL = "com.rumahazan.app/native"
        private const val EVENTS = "com.rumahazan.app/player_events"
        private const val REQ_NOTIF = 4101
    }

    private var pendingPermission: MethodChannel.Result? = null
    private var sink: EventChannel.EventSink? = null
    private val playerListener: (Map<String, Any?>) -> Unit = { s -> runOnUiThread { sink?.success(s) } }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        isRunning = true
        super.configureFlutterEngine(flutterEngine)
        Notifications.ensureChannels(this)
        BackgroundSyncJob.ensureScheduled(this)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                handle(call, result)
            } catch (t: Throwable) {
                result.error("native_error", t.message, null)
            }
        }
        EventChannel(messenger, EVENTS).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                sink = events
                PlaybackService.addListener(playerListener)
                events.success(PlaybackService.state)
            }

            override fun onCancel(arguments: Any?) {
                PlaybackService.removeListener(playerListener)
                sink = null
            }
        })
    }

    override fun onDestroy() {
        isRunning = false
        PlaybackService.removeListener(playerListener)
        super.onDestroy()
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        // Scheduler/data methods are shared with the background sync engine.
        if (SharedChannel.handle(this, call, result)) return
        when (call.method) {
            // ---- System / permissions ----
            "diagnostics" -> result.success(diagnostics())
            "requestNotificationPermission" -> requestNotificationPermission(result)
            "openExactAlarmSettings" -> {
                if (Build.VERSION.SDK_INT >= 31) {
                    open(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.parse("package:$packageName")))
                } else {
                    openAppDetails()
                }
                result.success(null)
            }
            "openBatteryOptimizationSettings" -> {
                if (!open(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))) openAppDetails()
                result.success(null)
            }
            "openNotificationSettings" -> {
                val i = if (Build.VERSION.SDK_INT >= 26) {
                    Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                } else {
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))
                }
                open(i)
                result.success(null)
            }
            "setKeepScreenOn" -> {
                if (call.argument<Boolean>("on") == true) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                }
                result.success(null)
            }
            "setWindowBrightness" -> {
                // Affects only this window; no system setting is modified.
                val v = (call.argument<Double>("value") ?: -1.0).toFloat()
                val lp = window.attributes
                lp.screenBrightness = if (v < 0f) WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE else v.coerceIn(0.01f, 1f)
                window.attributes = lp
                result.success(null)
            }

            // ---- Player ----
            "play" -> {
                val payload = JSONObject()
                val items = JSONArray()
                (call.argument<List<Map<String, Any?>>>("items") ?: emptyList()).forEach { items.put(JSONObject(it)) }
                payload.put("items", items)
                payload.put("title", call.argument<String>("title") ?: "")
                payload.put("startIndex", call.argument<Int>("startIndex") ?: 0)
                payload.put("volume", call.argument<Double>("volume") ?: 1.0)
                payload.put("repeatMode", call.argument<String>("repeatMode") ?: "off")
                payload.put("shuffle", call.argument<Boolean>("shuffle") ?: false)
                PlaybackService.playManual(this, payload)
                result.success(null)
            }
            "pause" -> cmd(PlaybackService.ACTION_PAUSE, result)
            "resume" -> cmd(PlaybackService.ACTION_RESUME, result)
            "stop" -> cmd(PlaybackService.ACTION_STOP, result)
            "next" -> cmd(PlaybackService.ACTION_NEXT, result)
            "previous" -> cmd(PlaybackService.ACTION_PREVIOUS, result)
            "seek" -> cmd(PlaybackService.ACTION_SEEK, result) { it.putExtra("ms", call.argument<Int>("ms") ?: 0) }
            "setVolume" -> cmd(PlaybackService.ACTION_VOLUME, result) {
                it.putExtra("volume", (call.argument<Double>("volume") ?: 1.0).toFloat())
            }
            "setRepeatMode" -> cmd(PlaybackService.ACTION_REPEAT, result) { it.putExtra("mode", call.argument<String>("mode") ?: "off") }
            "setShuffle" -> cmd(PlaybackService.ACTION_SHUFFLE, result) { it.putExtra("on", call.argument<Boolean>("on") ?: false) }
            "playerState" -> result.success(PlaybackService.state)
            else -> result.notImplemented()
        }
    }

    private fun cmd(action: String, result: MethodChannel.Result, extra: (Intent) -> Unit = {}) {
        PlaybackService.command(this, action, extra)
        result.success(null)
    }

    private fun open(i: Intent): Boolean = try {
        startActivity(i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        true
    } catch (_: ActivityNotFoundException) {
        false
    } catch (_: SecurityException) {
        false
    }

    private fun openAppDetails() {
        open(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")))
    }

    private fun notificationsEnabled(): Boolean =
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).areNotificationsEnabled()

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= 33 &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            pendingPermission?.success(false)
            pendingPermission = result
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQ_NOTIF)
        } else {
            result.success(notificationsEnabled())
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQ_NOTIF) {
            pendingPermission?.success(grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
            pendingPermission = null
        }
    }

    private fun diagnostics(): Map<String, Any?> {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val mi = ActivityManager.MemoryInfo().also { am.getMemoryInfo(it) }
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val ui = getSystemService(Context.UI_MODE_SERVICE) as UiModeManager
        val alarm = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val filter = when (nm.currentInterruptionFilter) {
            NotificationManager.INTERRUPTION_FILTER_ALL -> "all"
            NotificationManager.INTERRUPTION_FILTER_PRIORITY -> "priority"
            NotificationManager.INTERRUPTION_FILTER_ALARMS -> "alarms"
            NotificationManager.INTERRUPTION_FILTER_NONE -> "none"
            else -> "unknown"
        }
        return mapOf(
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT,
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "isTv" to (ui.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION ||
                packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)),
            "totalMemMb" to mi.totalMem / (1024 * 1024),
            "availMemMb" to mi.availMem / (1024 * 1024),
            "lowMemory" to mi.lowMemory,
            "notificationsEnabled" to nm.areNotificationsEnabled(),
            "exactAlarmAllowed" to (Build.VERSION.SDK_INT < 31 || alarm.canScheduleExactAlarms()),
            "batteryOptimizationIgnored" to pm.isIgnoringBatteryOptimizations(packageName),
            "interruptionFilter" to filter,
            "playbackActive" to PlaybackService.isActive(),
        )
    }
}
