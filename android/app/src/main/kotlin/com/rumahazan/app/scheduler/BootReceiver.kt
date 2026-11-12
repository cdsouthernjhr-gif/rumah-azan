package com.rumahazan.app.scheduler

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Re-arms the next alarm after events that clear or invalidate alarms:
 * device reboot, app update, manual clock change, timezone change, and the
 * exact-alarm permission being granted. Prayer times are absolute instants
 * (computed in Malaysian time), so a timezone change does not shift them.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            "android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED" -> {
                Scheduler.scheduleNext(ctx)
            }
        }
    }
}
