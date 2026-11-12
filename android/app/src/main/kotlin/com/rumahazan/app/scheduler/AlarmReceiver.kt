package com.rumahazan.app.scheduler

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import com.rumahazan.app.Notifications
import com.rumahazan.app.audio.PlaybackService
import org.json.JSONObject

/** Executes every due event, then arms the next alarm. */
class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(ctx: Context, intent: Intent) {
        if (intent.action != Scheduler.ACTION_FIRE) return
        val now = System.currentTimeMillis()
        val opts = Scheduler.options(ctx)
        val fired = Scheduler.firedIds(ctx)
        val due = Scheduler.events(ctx)
            .filter { !fired.contains(it.optString("id")) && it.optLong("triggerAtMs") <= now + 2000 }
            // Azan (priority 3) first so recitation is queued behind it.
            .sortedWith(compareByDescending<JSONObject> { it.optInt("priority", 1) }.thenBy { it.optLong("triggerAtMs") })

        Scheduler.markFired(ctx, due.map { it.optString("id") })
        Scheduler.setLastFired(ctx)
        for (e in due) {
            try {
                handle(ctx, e, now, opts)
            } catch (t: Throwable) {
                Scheduler.setLastError(ctx, "${e.optString("id")}: ${t.message}")
                Scheduler.recordHistory(ctx, e.optString("id"), e.optString("title"), "error", t.message)
            }
        }
        Scheduler.scheduleNext(ctx)
        warnIfPlanRunningOut(ctx, opts, now)
    }

    private fun handle(ctx: Context, e: JSONObject, now: Long, opts: JSONObject) {
        val late = now - e.optLong("triggerAtMs")
        val grace = e.optLong("graceMs", 5 * 60 * 1000L)
        val items = e.optJSONArray("items")
        val hasAudio = items != null && items.length() > 0
        val notify = e.optBoolean("notify", true)
        val vibrate = e.optBoolean("vibrate", false)
        var audioStarted = false

        if (hasAudio) {
            when {
                late > grace -> {
                    // Device was off/asleep too long: do not play stale audio.
                    Scheduler.recordHistory(ctx, e.optString("id"), e.optString("title"), "missed", "late ${late / 1000}s")
                    Notifications.showEvent(ctx, e, sound = false, vibrate = false,
                        overrideBody = opts.optString("missedTitle", "Audio tidak dimainkan"))
                    return
                }
                opts.optBoolean("respectSilent", true) && isSilenced(ctx) -> {
                    Scheduler.recordHistory(ctx, e.optString("id"), e.optString("title"), "skipped", "silent/dnd")
                    if (notify || e.optString("kind") == "azan") {
                        Notifications.showEvent(ctx, e, sound = false, vibrate = false,
                            overrideBody = opts.optString("silentSkippedBody", e.optString("body")))
                    }
                    return
                }
                else -> audioStarted = PlaybackService.startScheduled(ctx, e)
            }
        }
        if (notify) {
            // Sound only when no audio file is playing (fallback for azan).
            val sound = e.optBoolean("notifySound", false) && !audioStarted
            Notifications.showEvent(ctx, e, sound = sound || (hasAudio && !audioStarted), vibrate = vibrate)
        }
    }

    private fun isSilenced(ctx: Context): Boolean {
        val am = ctx.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (am.ringerMode != AudioManager.RINGER_MODE_NORMAL) return true
        val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val f = nm.currentInterruptionFilter
        return f != NotificationManager.INTERRUPTION_FILTER_ALL && f != NotificationManager.INTERRUPTION_FILTER_UNKNOWN
    }

    /** Once a day, warn if fewer than 24 h of events remain (app not opened). */
    private fun warnIfPlanRunningOut(ctx: Context, opts: JSONObject, now: Long) {
        val last = Scheduler.events(ctx).maxOfOrNull { it.optLong("triggerAtMs") } ?: 0L
        if (last - now > 24 * 3600 * 1000L) return
        val p = Scheduler.prefs(ctx)
        val day = now / (24 * 3600 * 1000L)
        if (p.getLong("lastRunOutWarnDay", -1) == day) return
        p.edit().putLong("lastRunOutWarnDay", day).apply()
        Notifications.showSystem(
            ctx, 9001,
            opts.optString("refreshTitle", "Rumah Azan"),
            opts.optString("refreshBody", "Buka aplikasi untuk mengemas kini jadual."),
        )
    }
}
