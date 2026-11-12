package com.rumahazan.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONObject

/**
 * Notification channels and helpers. Channels let the user control sound,
 * vibration and Do-Not-Disturb behaviour per category in system settings; the
 * app never bypasses those settings.
 */
object Notifications {
    const val CH_ALERT = "prayer_alert"            // high importance, default sound + vibration
    const val CH_ALERT_NOVIB = "prayer_alert_novib" // high importance, default sound, no vibration
    const val CH_SILENT = "prayer_silent"          // low importance, no sound
    const val CH_PLAYBACK = "playback"             // foreground playback service
    const val CH_SYSTEM = "system"                 // maintenance messages

    fun ensureChannels(ctx: Context) {
        if (Build.VERSION.SDK_INT < 26) return
        val nm = ctx.getSystemService(NotificationManager::class.java) ?: return
        val alert = NotificationChannel(CH_ALERT, "Waktu solat", NotificationManager.IMPORTANCE_HIGH).apply {
            description = "Pemberitahuan masuk waktu dan peringatan solat"
            enableVibration(true)
        }
        val alertNoVib = NotificationChannel(CH_ALERT_NOVIB, "Waktu solat (tanpa getaran)", NotificationManager.IMPORTANCE_HIGH).apply {
            enableVibration(false)
        }
        val silent = NotificationChannel(CH_SILENT, "Waktu solat (senyap)", NotificationManager.IMPORTANCE_LOW).apply {
            setSound(null, null)
            enableVibration(false)
        }
        val playback = NotificationChannel(CH_PLAYBACK, "Audio sedang dimainkan", NotificationManager.IMPORTANCE_LOW).apply {
            setSound(null, null)
            enableVibration(false)
            setShowBadge(false)
        }
        val system = NotificationChannel(CH_SYSTEM, "Sistem", NotificationManager.IMPORTANCE_DEFAULT)
        nm.createNotificationChannels(listOf(alert, alertNoVib, silent, playback, system))
    }

    @Suppress("DEPRECATION")
    fun builder(ctx: Context, channel: String): Notification.Builder =
        if (Build.VERSION.SDK_INT >= 26) Notification.Builder(ctx, channel) else Notification.Builder(ctx)

    fun contentIntent(ctx: Context): PendingIntent {
        val i = Intent(ctx, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(ctx, 0, i, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }

    fun canPost(ctx: Context): Boolean {
        val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return nm.areNotificationsEnabled()
    }

    /** Posts the notification for a scheduled event. */
    @Suppress("DEPRECATION")
    fun showEvent(ctx: Context, e: JSONObject, sound: Boolean, vibrate: Boolean, overrideBody: String? = null) {
        if (!canPost(ctx)) return
        ensureChannels(ctx)
        val channel = when {
            !sound -> CH_SILENT
            vibrate -> CH_ALERT
            else -> CH_ALERT_NOVIB
        }
        val b = builder(ctx, channel)
            .setSmallIcon(R.drawable.ic_stat_azan)
            .setContentTitle(e.optString("title"))
            .setContentText(overrideBody ?: e.optString("body"))
            .setContentIntent(contentIntent(ctx))
            .setAutoCancel(true)
            .setCategory(if (e.optString("kind") == "reminder") Notification.CATEGORY_REMINDER else Notification.CATEGORY_ALARM)
        if (Build.VERSION.SDK_INT < 26) {
            var defaults = 0
            if (sound) defaults = defaults or Notification.DEFAULT_SOUND
            if (vibrate && sound) defaults = defaults or Notification.DEFAULT_VIBRATE
            b.setDefaults(defaults)
            b.setPriority(if (sound) Notification.PRIORITY_HIGH else Notification.PRIORITY_LOW)
        }
        val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(e.optString("id").hashCode(), b.build())
    }

    fun showSystem(ctx: Context, id: Int, title: String, body: String) {
        if (!canPost(ctx)) return
        ensureChannels(ctx)
        val b = builder(ctx, CH_SYSTEM)
            .setSmallIcon(R.drawable.ic_stat_azan)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setContentIntent(contentIntent(ctx))
            .setAutoCancel(true)
        val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(id, b.build())
    }
}
