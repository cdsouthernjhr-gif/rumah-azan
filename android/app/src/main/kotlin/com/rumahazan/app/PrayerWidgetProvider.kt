package com.rumahazan.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import com.rumahazan.app.scheduler.Scheduler
import org.json.JSONObject

/**
 * Home-screen widget: next prayer with a live countdown, today's six times
 * (next one highlighted), Gregorian + Hijri date, zone and the first pinned
 * day countdown.
 *
 * Flutter prepares the data (31 days, localised labels) via
 * [save]; this class only chooses what applies "now". The countdown is an
 * Android Chronometer, so it ticks without waking the app. The widget
 * redraws itself at the next prayer change and at Malaysian midnight using a
 * NON-wakeup alarm (no battery cost while the screen is off).
 */
class PrayerWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS = "rumahazan_widget"
        private const val ACTION_REFRESH = "com.rumahazan.app.WIDGET_REFRESH"
        private const val REQUEST_CODE = 2001
        private const val MYT_OFFSET_MS = 8 * 60 * 60 * 1000L
        private const val DAY_MS = 24 * 60 * 60 * 1000L

        private val nameIds = intArrayOf(R.id.name_0, R.id.name_1, R.id.name_2, R.id.name_3, R.id.name_4, R.id.name_5)
        private val timeIds = intArrayOf(R.id.time_0, R.id.time_1, R.id.time_2, R.id.time_3, R.id.time_4, R.id.time_5)
        private val cellIds = intArrayOf(R.id.cell_0, R.id.cell_1, R.id.cell_2, R.id.cell_3, R.id.cell_4, R.id.cell_5)

        /** Stores new data from Flutter and redraws all placed widgets. */
        fun save(ctx: Context, payload: JSONObject) {
            ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString("payload", payload.toString()).apply()
            refreshAll(ctx)
        }

        fun refreshAll(ctx: Context) {
            val mgr = AppWidgetManager.getInstance(ctx) ?: return
            val ids = mgr.getAppWidgetIds(ComponentName(ctx, PrayerWidgetProvider::class.java))
            if (ids.isEmpty()) return
            var nextBoundary = Long.MAX_VALUE
            for (id in ids) nextBoundary = minOf(nextBoundary, render(ctx, mgr, id))
            scheduleNext(ctx, nextBoundary)
        }

        private fun payload(ctx: Context): JSONObject? = try {
            ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString("payload", null)?.let { JSONObject(it) }
        } catch (_: Exception) {
            null
        }

        // java.time needs API 26; minSdk is 24, so convert dates by hand
        // (Howard Hinnant's civil-from-days / days-from-civil algorithms).
        fun civilFromDays(z0: Long): Triple<Int, Int, Int> {
            val z = z0 + 719468
            val era = Math.floorDiv(z, 146097L)
            val doe = z - era * 146097
            val yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365
            val doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
            val mp = (5 * doy + 2) / 153
            val d = (doy - (153 * mp + 2) / 5 + 1).toInt()
            val m = (if (mp < 10) mp + 3 else mp - 9).toInt()
            val y = (yoe + era * 400 + if (m <= 2) 1 else 0).toInt()
            return Triple(y, m, d)
        }

        fun daysFromCivil(y0: Int, m: Int, d: Int): Long {
            val y = (if (m <= 2) y0 - 1 else y0).toLong()
            val era = Math.floorDiv(y, 400L)
            val yoe = y - era * 400
            val mp = (m + 9) % 12
            val doy = (153 * mp + 2) / 5 + d - 1
            val doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
            return era * 146097 + doe - 719468
        }

        /** yyyy-MM-dd of the Malaysian civil date for [ms]. */
        fun mytDateKey(ms: Long): String {
            val (y, m, d) = civilFromDays(Math.floorDiv(ms + MYT_OFFSET_MS, DAY_MS))
            return String.format(java.util.Locale.US, "%04d-%02d-%02d", y, m, d)
        }

        private fun epochDay(key: String): Long {
            val parts = key.split("-").map { it.toInt() }
            return daysFromCivil(parts[0], parts[1], parts[2])
        }

        fun mytHhmm(ms: Long): String {
            val m = Math.floorMod((ms + MYT_OFFSET_MS) / 60000, 1440L)
            return String.format(java.util.Locale.US, "%02d:%02d", m / 60, m % 60)
        }

        private fun nextMytMidnight(now: Long): Long =
            (Math.floorDiv(now + MYT_OFFSET_MS, DAY_MS) + 1) * DAY_MS - MYT_OFFSET_MS

        private fun daysBetween(from: String, to: String): Long = epochDay(to) - epochDay(from)

        /** Draws one widget; returns the instant at which it must be redrawn. */
        private fun render(ctx: Context, mgr: AppWidgetManager, widgetId: Int): Long {
            val now = System.currentTimeMillis()
            val today = mytDateKey(now)
            val v = RemoteViews(ctx.packageName, R.layout.widget_prayer)
            val open = PendingIntent.getActivity(
                ctx, 0, Intent(ctx, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            v.setOnClickPendingIntent(R.id.widget_root, open)
            var boundary = nextMytMidnight(now) + 1000

            val p = payload(ctx)
            val days = p?.optJSONArray("days")
            val labels = p?.optJSONObject("labels")
            val names = labels?.optJSONArray("prayers")
            v.setTextViewText(R.id.zone, p?.optString("zone")?.ifEmpty { null } ?: "Rumah Azan")

            // Today's entry (or the first future one) and the next prayer.
            var dayObj: JSONObject? = null
            var nextMs = -1L
            var nextIdx = -1
            var nextIsToday = false
            if (days != null) {
                for (i in 0 until days.length()) {
                    val d = days.optJSONObject(i) ?: continue
                    val date = d.optString("date")
                    if (date < today) continue
                    if (dayObj == null) dayObj = d
                    val times = d.optJSONArray("times") ?: continue
                    for (k in 0 until times.length()) {
                        val t = times.optLong(k)
                        if (t > now) {
                            nextMs = t; nextIdx = k; nextIsToday = date == today
                            break
                        }
                    }
                    if (nextMs > 0) break
                }
            }

            if (dayObj == null || nextMs <= 0 || names == null) {
                v.setTextViewText(R.id.date, "")
                v.setTextViewText(R.id.next_name, labels?.optString("noData") ?: "Buka Rumah Azan untuk memuat turun waktu solat")
                v.setViewVisibility(R.id.countdown, View.GONE)
                v.setViewVisibility(R.id.times_row, View.GONE)
                v.setViewVisibility(R.id.countdown_line, View.GONE)
                v.setViewVisibility(R.id.estimate, View.GONE)
                mgr.updateAppWidget(widgetId, v)
                return boundary
            }

            v.setTextViewText(R.id.date, "${dayObj.optString("gregorian")} · ${dayObj.optString("hijri")}")
            v.setTextViewText(R.id.next_name, "${names.optString(nextIdx)} ${mytHhmm(nextMs)}")
            v.setViewVisibility(R.id.countdown, View.VISIBLE)
            v.setChronometer(R.id.countdown, SystemClock.elapsedRealtime() + (nextMs - now), null, true)
            v.setChronometerCountDown(R.id.countdown, true)
            boundary = minOf(boundary, nextMs + 1000)

            val times = dayObj.optJSONArray("times")
            v.setViewVisibility(R.id.times_row, View.VISIBLE)
            for (k in 0 until 6) {
                v.setTextViewText(nameIds[k], names.optString(k))
                v.setTextViewText(timeIds[k], times?.let { mytHhmm(it.optLong(k)) } ?: "--:--")
                val active = nextIsToday && k == nextIdx
                v.setInt(cellIds[k], "setBackgroundResource", if (active) R.drawable.widget_cell_active else R.drawable.widget_cell)
            }

            // First pinned day countdown, e.g. "Awal Ramadan · 85 hari lagi".
            val cd = p.optJSONObject("countdown")
            val cdDate = cd?.optString("dateKey")?.ifEmpty { null }
            val cdDays = cdDate?.let { daysBetween(today, it) }
            if (cd != null && cdDays != null && cdDays >= 0) {
                val txt = when (cdDays) {
                    0L -> labels.optString("cdToday")
                    1L -> labels.optString("cdTomorrow")
                    else -> labels.optString("cdDaysLeft").replace("{n}", cdDays.toString())
                }
                val star = if (cd.optBoolean("calculated")) " *" else ""
                v.setTextViewText(R.id.countdown_line, "${cd.optString("title")} · $txt$star")
                v.setViewVisibility(R.id.countdown_line, View.VISIBLE)
            } else {
                v.setViewVisibility(R.id.countdown_line, View.GONE)
            }

            if (dayObj.optBoolean("estimated")) {
                v.setTextViewText(R.id.estimate, labels.optString("estimate"))
                v.setViewVisibility(R.id.estimate, View.VISIBLE)
            } else {
                v.setViewVisibility(R.id.estimate, View.GONE)
            }

            // Small (1-row) widgets: hide the six-times row and the date.
            val opts: Bundle = mgr.getAppWidgetOptions(widgetId)
            val minH = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)
            if (minH in 1 until 100) {
                v.setViewVisibility(R.id.times_row, View.GONE)
                v.setViewVisibility(R.id.date, View.GONE)
            } else {
                v.setViewVisibility(R.id.date, View.VISIBLE)
            }

            mgr.updateAppWidget(widgetId, v)
            return boundary
        }

        /** Non-wakeup alarm: redraws when the device is next awake. */
        private fun scheduleNext(ctx: Context, at: Long) {
            if (at == Long.MAX_VALUE) return
            val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val pi = PendingIntent.getBroadcast(
                ctx, REQUEST_CODE,
                Intent(ctx, PrayerWidgetProvider::class.java).setAction(ACTION_REFRESH),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            try {
                if (Scheduler.canScheduleExact(ctx)) am.setExact(AlarmManager.RTC, at, pi) else am.set(AlarmManager.RTC, at, pi)
            } catch (_: SecurityException) {
                am.set(AlarmManager.RTC, at, pi)
            }
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        refreshAll(context)
    }

    override fun onAppWidgetOptionsChanged(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, newOptions: Bundle) {
        refreshAll(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_REFRESH) refreshAll(context)
    }

    override fun onDisabled(context: Context) {
        // Last widget removed: stop the refresh alarm.
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = PendingIntent.getBroadcast(
            context, REQUEST_CODE,
            Intent(context, PrayerWidgetProvider::class.java).setAction(ACTION_REFRESH),
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
        )
        if (pi != null) am.cancel(pi)
    }
}
