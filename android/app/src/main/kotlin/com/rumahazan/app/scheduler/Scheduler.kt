package com.rumahazan.app.scheduler

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.rumahazan.app.MainActivity
import org.json.JSONArray
import org.json.JSONObject

/**
 * Persistent alarm plan.
 *
 * Design:
 *  - Flutter computes the full plan (7 days) with deterministic event ids and
 *    hands it over with [sync]; the whole list is replaced each time, so
 *    re-planning can never create duplicates.
 *  - Only ONE AlarmManager alarm is armed at a time: the earliest pending
 *    event. When it fires, every due event is processed and the next one is
 *    armed ("chained" alarms). This keeps background work minimal.
 *  - The plan lives in SharedPreferences so it survives process death, reboot
 *    and app updates (BootReceiver re-arms it).
 */
object Scheduler {
    private const val PREFS = "rumahazan_scheduler"
    const val ACTION_FIRE = "com.rumahazan.app.ACTION_FIRE"
    private const val REQUEST_CODE = 1001
    private const val MAX_HISTORY = 200

    fun prefs(ctx: Context) = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    @Synchronized
    fun sync(ctx: Context, events: JSONArray, options: JSONObject): Int {
        val now = System.currentTimeMillis()
        val fired = firedIds(ctx)
        val kept = JSONArray()
        val seen = HashSet<String>()
        val keptFired = HashSet<String>()
        for (i in 0 until events.length()) {
            val e = events.optJSONObject(i) ?: continue
            val id = e.optString("id")
            val at = e.optLong("triggerAtMs")
            if (id.isEmpty() || at <= 0) continue
            if (!seen.add(id)) continue                      // duplicate id
            if (at + e.optLong("graceMs", 0) < now) continue  // too old
            // Already-fired events stay in the list (marked fired) so they
            // are never fired twice if re-sent.
            if (fired.contains(id)) keptFired.add(id)
            kept.put(e)
        }
        prefs(ctx).edit()
            .putString("events", kept.toString())
            .putString("options", options.toString())
            .putStringSet("fired", keptFired)
            .putLong("lastSyncAtMs", now)
            .apply()
        scheduleNext(ctx)
        return kept.length()
    }

    @Synchronized
    fun addEvent(ctx: Context, e: JSONObject) {
        val list = JSONArray(prefs(ctx).getString("events", "[]"))
        list.put(e)
        prefs(ctx).edit().putString("events", list.toString()).apply()
        scheduleNext(ctx)
    }

    fun events(ctx: Context): List<JSONObject> {
        val arr = try { JSONArray(prefs(ctx).getString("events", "[]")) } catch (_: Exception) { JSONArray() }
        return (0 until arr.length()).mapNotNull { arr.optJSONObject(it) }.sortedBy { it.optLong("triggerAtMs") }
    }

    fun options(ctx: Context): JSONObject =
        try { JSONObject(prefs(ctx).getString("options", "{}") ?: "{}") } catch (_: Exception) { JSONObject() }

    fun firedIds(ctx: Context): MutableSet<String> = HashSet(prefs(ctx).getStringSet("fired", emptySet()) ?: emptySet())

    @Synchronized
    fun markFired(ctx: Context, ids: Collection<String>) {
        val set = firedIds(ctx)
        set.addAll(ids)
        // Drop fired ids whose events are long gone to keep prefs small.
        val live = events(ctx).map { it.optString("id") }.toSet()
        set.retainAll(live)
        prefs(ctx).edit().putStringSet("fired", set).apply()
    }

    fun canScheduleExact(ctx: Context): Boolean {
        if (Build.VERSION.SDK_INT < 31) return true
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        return am.canScheduleExactAlarms()
    }

    private fun firePendingIntent(ctx: Context): PendingIntent {
        val i = Intent(ctx, AlarmReceiver::class.java).setAction(ACTION_FIRE)
        return PendingIntent.getBroadcast(ctx, REQUEST_CODE, i, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }

    /** Arms the alarm for the earliest pending event (or cancels if none). */
    @Synchronized
    fun scheduleNext(ctx: Context): JSONObject? {
        val now = System.currentTimeMillis()
        val fired = firedIds(ctx)
        val next = events(ctx).firstOrNull {
            !fired.contains(it.optString("id")) && it.optLong("triggerAtMs") + it.optLong("graceMs", 0) >= now
        }
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = firePendingIntent(ctx)
        val edit = prefs(ctx).edit()
        if (next == null) {
            am.cancel(pi)
            edit.remove("nextId").remove("nextTitle").remove("nextAtMs").putString("alarmMode", "none").apply()
            return null
        }
        // Event already due (e.g. right after reboot, within grace) → fire now.
        val at = maxOf(next.optLong("triggerAtMs"), now + 1000)
        val mode: String
        if (canScheduleExact(ctx)) {
            // setAlarmClock is exempt from Doze throttling and allows the
            // receiver to start a foreground media service on Android 12+.
            val show = PendingIntent.getActivity(
                ctx, 0, Intent(ctx, MainActivity::class.java),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            am.setAlarmClock(AlarmManager.AlarmClockInfo(at, show), pi)
            mode = "exact (alarm clock)"
        } else {
            // Without the exact-alarm permission the system may delay this.
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi)
            mode = "inexact (permission not granted)"
        }
        edit.putString("nextId", next.optString("id"))
            .putString("nextTitle", next.optString("title"))
            .putLong("nextAtMs", at)
            .putString("alarmMode", mode)
            .apply()
        return next
    }

    @Synchronized
    fun cancelAll(ctx: Context) {
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.cancel(firePendingIntent(ctx))
        prefs(ctx).edit().putString("events", "[]").putStringSet("fired", emptySet())
            .remove("nextId").remove("nextTitle").remove("nextAtMs").putString("alarmMode", "none").apply()
    }

    fun status(ctx: Context): Map<String, Any?> {
        val p = prefs(ctx)
        val fired = firedIds(ctx)
        return mapOf(
            "count" to events(ctx).count { !fired.contains(it.optString("id")) },
            "nextId" to p.getString("nextId", null),
            "nextTitle" to p.getString("nextTitle", null),
            "nextAtMs" to p.getLong("nextAtMs", 0L),
            "alarmMode" to p.getString("alarmMode", "none"),
            "exactAllowed" to canScheduleExact(ctx),
            "lastSyncAtMs" to p.getLong("lastSyncAtMs", 0L),
            "lastFiredAtMs" to p.getLong("lastFiredAtMs", 0L),
            "lastPlaybackAtMs" to p.getLong("lastPlaybackAtMs", 0L),
            "lastPlaybackTitle" to p.getString("lastPlaybackTitle", null),
            "lastErrorAtMs" to p.getLong("lastErrorAtMs", 0L),
            "lastError" to p.getString("lastError", null),
        )
    }

    fun setLastPlayback(ctx: Context, title: String) {
        prefs(ctx).edit().putLong("lastPlaybackAtMs", System.currentTimeMillis()).putString("lastPlaybackTitle", title).apply()
    }

    fun setLastError(ctx: Context, error: String) {
        prefs(ctx).edit().putLong("lastErrorAtMs", System.currentTimeMillis()).putString("lastError", error).apply()
    }

    fun setLastFired(ctx: Context) {
        prefs(ctx).edit().putLong("lastFiredAtMs", System.currentTimeMillis()).apply()
    }

    /** Appends a playback history entry, later imported by Flutter. */
    @Synchronized
    fun recordHistory(ctx: Context, eventId: String?, title: String, status: String, detail: String? = null) {
        val arr = try { JSONArray(prefs(ctx).getString("history", "[]")) } catch (_: Exception) { JSONArray() }
        arr.put(JSONObject().apply {
            put("eventId", eventId ?: JSONObject.NULL)
            put("title", title)
            put("status", status)
            put("detail", detail ?: JSONObject.NULL)
            put("at", System.currentTimeMillis())
        })
        val trimmed = JSONArray()
        val start = maxOf(0, arr.length() - MAX_HISTORY)
        for (i in start until arr.length()) trimmed.put(arr.get(i))
        prefs(ctx).edit().putString("history", trimmed.toString()).apply()
    }

    @Synchronized
    fun drainHistory(ctx: Context): List<Map<String, Any?>> {
        val arr = try { JSONArray(prefs(ctx).getString("history", "[]")) } catch (_: Exception) { JSONArray() }
        prefs(ctx).edit().putString("history", "[]").apply()
        return (0 until arr.length()).mapNotNull { i ->
            val o = arr.optJSONObject(i) ?: return@mapNotNull null
            mapOf(
                "eventId" to (if (o.isNull("eventId")) null else o.optString("eventId")),
                "title" to o.optString("title"),
                "status" to o.optString("status"),
                "detail" to (if (o.isNull("detail")) null else o.optString("detail")),
                "at" to o.optLong("at"),
            )
        }
    }
}
