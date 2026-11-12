package com.rumahazan.app

import android.content.Context
import android.media.MediaMetadataRetriever
import android.os.Handler
import android.os.Looper
import com.rumahazan.app.scheduler.Scheduler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

/**
 * Methods that need no Activity (scheduler, history, metadata). Used by both
 * the UI engine (MainActivity) and the headless background-sync engine.
 */
object SharedChannel {
    const val CHANNEL = "com.rumahazan.app/native"

    /** Returns true if [call] was handled. */
    fun handle(ctx: Context, call: MethodCall, result: MethodChannel.Result): Boolean {
        when (call.method) {
            "ping" -> result.success(true)
            "syncSchedule" -> {
                val events = JSONArray()
                (call.argument<List<Map<String, Any?>>>("events") ?: emptyList()).forEach { events.put(JSONObject(it)) }
                val options = JSONObject(call.argument<Map<String, Any?>>("options") ?: emptyMap<String, Any?>())
                result.success(Scheduler.sync(ctx, events, options))
            }
            "cancelSchedule" -> {
                Scheduler.cancelAll(ctx)
                result.success(null)
            }
            "schedulerStatus" -> result.success(
                Scheduler.status(ctx) + mapOf("lastBackgroundSyncAtMs" to BackgroundSyncJob.lastRunAt(ctx)),
            )
            "scheduleTestEvent" -> {
                val secs = call.argument<Int>("seconds") ?: 15
                val now = System.currentTimeMillis()
                Scheduler.addEvent(ctx, JSONObject().apply {
                    put("id", "test_$now")
                    put("triggerAtMs", now + secs * 1000L)
                    put("kind", "test")
                    put("title", call.argument<String>("title") ?: "Rumah Azan")
                    put("body", call.argument<String>("body") ?: "")
                    put("items", JSONArray())
                    put("notify", true)
                    put("notifySound", true)
                    put("vibrate", true)
                    put("graceMs", 60_000)
                    put("priority", 1)
                })
                result.success(true)
            }
            "drainPlaybackHistory" -> result.success(Scheduler.drainHistory(ctx))
            "audioDuration" -> {
                // Off the main thread: metadata extraction reads the file.
                val path = call.argument<String>("path") ?: ""
                val main = Handler(Looper.getMainLooper())
                Thread {
                    val ms = readDurationMs(path)
                    main.post { result.success(ms) }
                }.start()
            }
            else -> return false
        }
        return true
    }

    private fun readDurationMs(path: String): Long? {
        val r = MediaMetadataRetriever()
        return try {
            r.setDataSource(path)
            r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull()
        } catch (_: Exception) {
            null
        } finally {
            try {
                r.release()
            } catch (_: Exception) {
            }
        }
    }
}
