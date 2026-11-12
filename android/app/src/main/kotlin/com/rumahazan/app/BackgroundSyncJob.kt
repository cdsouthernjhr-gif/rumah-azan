package com.rumahazan.app

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Daily background refresh while the app is closed.
 *
 * JobScheduler (framework API, no Google Play Services) runs this at most
 * once a day when a network is available. It starts a headless Flutter engine
 * that executes the Dart entry point `backgroundSyncMain` (lib/main.dart),
 * which refreshes the JAKIM timetable if needed and re-plans the alarms
 * through the same channel the UI uses. This way the planning logic exists
 * only once (in Dart) and the 30-day alarm horizon keeps rolling forward
 * even if the user never opens the app.
 */
class BackgroundSyncJob : JobService() {

    companion object {
        private const val JOB_ID = 7301
        private const val TIMEOUT_MS = 4 * 60 * 1000L
        private const val PREFS = "rumahazan_background"

        /**
         * Idempotent: schedules the periodic job only if not already pending.
         * Never throws: a scheduling problem must not stop the app opening
         * (it is reported in Diagnostics instead).
         */
        fun ensureScheduled(ctx: Context) {
            try {
                val js = ctx.getSystemService(Context.JOB_SCHEDULER_SERVICE) as JobScheduler
                if (js.getPendingJob(JOB_ID) != null) return
                val info = JobInfo.Builder(JOB_ID, ComponentName(ctx, BackgroundSyncJob::class.java))
                    .setPeriodic(24 * 60 * 60 * 1000L)
                    .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY) // needs ACCESS_NETWORK_STATE
                    .setPersisted(true) // survives reboot (RECEIVE_BOOT_COMPLETED)
                    .build()
                js.schedule(info)
            } catch (t: Throwable) {
                com.rumahazan.app.scheduler.Scheduler.setLastError(ctx, "Background job: ${t.javaClass.simpleName}: ${t.message}")
            }
        }

        fun lastRunAt(ctx: Context): Long =
            ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getLong("lastRunAtMs", 0L)
    }

    private var engine: FlutterEngine? = null
    private val handler = Handler(Looper.getMainLooper())
    private var params: JobParameters? = null

    override fun onStartJob(params: JobParameters): Boolean {
        this.params = params
        return try {
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(applicationContext)
            loader.ensureInitializationComplete(applicationContext, null)
            // Plugins (path_provider, sqlite, http) register automatically.
            val e = FlutterEngine(applicationContext)
            engine = e
            MethodChannel(e.dartExecutor.binaryMessenger, SharedChannel.CHANNEL).setMethodCallHandler { call, result ->
                if (call.method == "backgroundDone") {
                    result.success(null)
                    getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                        .putLong("lastRunAtMs", System.currentTimeMillis())
                        .putBoolean("lastOk", call.argument<Boolean>("ok") == true)
                        .apply()
                    finish(needsReschedule = false)
                } else if (!SharedChannel.handle(applicationContext, call, result)) {
                    result.notImplemented() // UI-only methods are unavailable here
                }
            }
            e.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "backgroundSyncMain"),
            )
            handler.postDelayed({ finish(needsReschedule = true) }, TIMEOUT_MS)
            true // work continues asynchronously
        } catch (t: Throwable) {
            com.rumahazan.app.scheduler.Scheduler.setLastError(this, "Background sync: ${t.message}")
            false
        }
    }

    override fun onStopJob(params: JobParameters): Boolean {
        destroyEngine()
        return true // system stopped us early → retry later
    }

    private fun finish(needsReschedule: Boolean) {
        handler.removeCallbacksAndMessages(null)
        destroyEngine()
        params?.let { jobFinished(it, needsReschedule) }
        params = null
    }

    private fun destroyEngine() {
        engine?.destroy()
        engine = null
    }
}
