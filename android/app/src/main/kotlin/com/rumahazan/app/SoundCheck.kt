package com.rumahazan.app

import android.app.NotificationManager
import android.content.Context
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build

/** Everything that can silence Rumah Azan, in one map (Diagnostics → Bunyi). */
object SoundCheck {
    fun status(ctx: Context): Map<String, Any?> {
        val am = ctx.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        fun vol(stream: Int) = mapOf("cur" to am.getStreamVolume(stream), "max" to am.getStreamMaxVolume(stream))
        val ringer = when (am.ringerMode) {
            AudioManager.RINGER_MODE_NORMAL -> "normal"
            AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
            else -> "silent"
        }
        val dnd = when (nm.currentInterruptionFilter) {
            NotificationManager.INTERRUPTION_FILTER_ALL, NotificationManager.INTERRUPTION_FILTER_UNKNOWN -> false
            else -> true
        }
        val channels = mutableMapOf<String, Any?>()
        if (Build.VERSION.SDK_INT >= 26) {
            Notifications.ensureChannels(ctx)
            for (id in listOf(Notifications.CH_ALERT, Notifications.CH_ALERT_NOVIB, Notifications.CH_SYSTEM)) {
                val ch = nm.getNotificationChannel(id) ?: continue
                channels[id] = mapOf(
                    "importance" to ch.importance, // 0 = blocked by the user
                    "hasSound" to (ch.sound != null),
                )
            }
        }
        return mapOf(
            "ringerMode" to ringer,
            "dnd" to dnd,
            "notificationsEnabled" to nm.areNotificationsEnabled(),
            "exactAlarmAllowed" to com.rumahazan.app.scheduler.Scheduler.canScheduleExact(ctx),
            "music" to vol(AudioManager.STREAM_MUSIC),
            "alarm" to vol(AudioManager.STREAM_ALARM),
            "notification" to vol(AudioManager.STREAM_NOTIFICATION),
            "channels" to channels,
            "respectSilent" to com.rumahazan.app.scheduler.Scheduler.options(ctx).optBoolean("respectSilent", true),
        )
    }

    /**
     * Short audible click for the tasbih. Uses the media stream, so it does
     * not depend on the system "touch sounds" setting (off by default on many
     * phones, which made SystemSound.click silent).
     */
    @Volatile
    private var tone: ToneGenerator? = null

    fun click(volumePercent: Int = 60) {
        try {
            val t = tone ?: ToneGenerator(AudioManager.STREAM_MUSIC, volumePercent.coerceIn(0, 100)).also { tone = it }
            t.startTone(ToneGenerator.TONE_PROP_BEEP, 60)
        } catch (_: Throwable) {
            tone = null // ToneGenerator can fail if the audio system is busy
        }
    }
}
