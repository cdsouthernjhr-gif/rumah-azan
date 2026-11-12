package com.rumahazan.app.audio

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.SystemClock
import com.rumahazan.app.Notifications
import com.rumahazan.app.R
import com.rumahazan.app.scheduler.Scheduler
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.util.concurrent.CopyOnWriteArraySet

/**
 * The single audio engine for both manual playback and scheduled azan /
 * recitation, so two sources can never overlap:
 *  - a scheduled event with HIGHER priority (azan) interrupts what is playing;
 *  - equal/lower priority scheduled events are queued after the current one;
 *  - manual playback replaces the current session (explicit user action).
 *
 * Runs as a foreground service of type mediaPlayback (Android 14+), holds
 * audio focus while playing, and stops itself when idle.
 */
class PlaybackService : Service(), AudioManager.OnAudioFocusChangeListener {

    data class Item(val path: String, val title: String)

    class Session(
        val items: List<Item>,
        val title: String,
        val source: String,          // manual | scheduled
        val eventId: String?,
        val priority: Int,
        var volume: Float,
        val maxDurationMs: Long,
        var repeatsLeft: Int,        // scheduled: remaining playlist repeats
        val startIndex: Int = 0,
    )

    companion object {
        const val ACTION_PLAY_SCHEDULED = "com.rumahazan.app.PLAY_SCHEDULED"
        const val ACTION_PLAY_MANUAL = "com.rumahazan.app.PLAY_MANUAL"
        const val ACTION_PAUSE = "com.rumahazan.app.PAUSE"
        const val ACTION_RESUME = "com.rumahazan.app.RESUME"
        const val ACTION_STOP = "com.rumahazan.app.STOP"
        const val ACTION_NEXT = "com.rumahazan.app.NEXT"
        const val ACTION_PREVIOUS = "com.rumahazan.app.PREVIOUS"
        const val ACTION_SEEK = "com.rumahazan.app.SEEK"
        const val ACTION_VOLUME = "com.rumahazan.app.VOLUME"
        const val ACTION_REPEAT = "com.rumahazan.app.REPEAT"
        const val ACTION_SHUFFLE = "com.rumahazan.app.SHUFFLE"
        private const val NOTIF_ID = 4242

        private val idle: Map<String, Any?> = mapOf("state" to "idle")

        @Volatile
        var state: Map<String, Any?> = idle
            private set

        @Volatile
        private var running = false

        private val listeners = CopyOnWriteArraySet<(Map<String, Any?>) -> Unit>()
        fun addListener(l: (Map<String, Any?>) -> Unit) = listeners.add(l)
        fun removeListener(l: (Map<String, Any?>) -> Unit) = listeners.remove(l)
        fun isActive() = running && state["state"] != "idle"

        private fun publish(s: Map<String, Any?>) {
            state = s
            for (l in listeners) l(s)
        }

        /** Called from the alarm receiver. Returns false if it could not start. */
        fun startScheduled(ctx: Context, event: JSONObject): Boolean {
            val i = Intent(ctx, PlaybackService::class.java)
                .setAction(ACTION_PLAY_SCHEDULED)
                .putExtra("event", event.toString())
            return try {
                if (Build.VERSION.SDK_INT >= 26) ctx.startForegroundService(i) else ctx.startService(i)
                true
            } catch (t: Throwable) {
                // e.g. ForegroundServiceStartNotAllowedException when only an
                // inexact alarm was available on Android 12+.
                Scheduler.setLastError(ctx, "Tidak dapat memulakan audio: ${t.javaClass.simpleName}")
                Scheduler.recordHistory(ctx, event.optString("id"), event.optString("title"), "error", t.message)
                false
            }
        }

        fun playManual(ctx: Context, payload: JSONObject) {
            val i = Intent(ctx, PlaybackService::class.java)
                .setAction(ACTION_PLAY_MANUAL)
                .putExtra("payload", payload.toString())
            if (Build.VERSION.SDK_INT >= 26) ctx.startForegroundService(i) else ctx.startService(i)
        }

        /** Control commands; ignored when the service is not running. */
        fun command(ctx: Context, action: String, extra: (Intent) -> Unit = {}) {
            if (!running) return
            val i = Intent(ctx, PlaybackService::class.java).setAction(action)
            extra(i)
            ctx.startService(i)
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var player: MediaPlayer? = null
    private var session: Session? = null
    private val pending = ArrayDeque<Session>()
    private var order: MutableList<Int> = mutableListOf()
    private var pos = 0
    private var repeatMode = "off"
    private var shuffle = false
    private var stopAtElapsed = 0L
    private var prepared = false
    private var pausedByFocus = false
    private var ducked = false
    private var focusRequest: AudioFocusRequest? = null
    private lateinit var audioManager: AudioManager

    private val ticker = object : Runnable {
        override fun run() {
            if (stopAtElapsed > 0 && SystemClock.elapsedRealtime() >= stopAtElapsed) {
                finishSession("max_duration")
                return
            }
            emit()
            handler.postDelayed(this, 500)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        running = true
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        Notifications.ensureChannels(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == ACTION_PLAY_SCHEDULED || action == ACTION_PLAY_MANUAL) {
            // Must call startForeground promptly after startForegroundService.
            goForeground(getString(R.string.app_name), "")
        }
        try {
            when (action) {
                ACTION_PLAY_SCHEDULED -> onScheduled(JSONObject(intent.getStringExtra("event") ?: "{}"))
                ACTION_PLAY_MANUAL -> onManual(JSONObject(intent.getStringExtra("payload") ?: "{}"))
                ACTION_PAUSE -> pause()
                ACTION_RESUME -> resume()
                ACTION_STOP -> {
                    pending.clear()
                    finishSession("stopped")
                }
                ACTION_NEXT -> advance(userInitiated = true)
                ACTION_PREVIOUS -> previous()
                ACTION_SEEK -> if (prepared) player?.seekTo(intent.getIntExtra("ms", 0))
                ACTION_VOLUME -> {
                    val v = intent.getFloatExtra("volume", 1f).coerceIn(0f, 1f)
                    session?.volume = v
                    applyVolume()
                }
                ACTION_REPEAT -> repeatMode = intent.getStringExtra("mode") ?: "off"
                ACTION_SHUFFLE -> {
                    shuffle = intent.getBooleanExtra("on", false)
                    rebuildOrder(keepCurrent = true)
                }
            }
        } catch (t: Throwable) {
            Scheduler.setLastError(this, "Playback: ${t.message}")
            finishSession("error")
        }
        if (session == null && pending.isEmpty()) stopIfIdle()
        emit()
        return START_NOT_STICKY
    }

    // ---- Session management ------------------------------------------------

    private fun parseItems(arr: JSONArray?): List<Item> =
        (0 until (arr?.length() ?: 0)).mapNotNull { i ->
            val o = arr!!.optJSONObject(i) ?: return@mapNotNull null
            Item(o.optString("path"), o.optString("title"))
        }

    private fun onScheduled(e: JSONObject) {
        val s = Session(
            items = parseItems(e.optJSONArray("items")),
            title = e.optString("title"),
            source = "scheduled",
            eventId = e.optString("id"),
            priority = e.optInt("priority", 1),
            volume = e.optDouble("volume", 1.0).toFloat(),
            maxDurationMs = e.optLong("maxDurationMs", 0),
            repeatsLeft = maxOf(0, e.optInt("repeat", 1) - 1),
        )
        if (s.items.isEmpty()) return
        val cur = session
        when {
            cur == null -> startSession(s)
            s.priority > cur.priority -> {
                if (cur.source == "scheduled") {
                    Scheduler.recordHistory(this, cur.eventId, cur.title, "interrupted", "by ${s.eventId}")
                }
                startSession(s)
            }
            else -> pending.addLast(s)
        }
    }

    private fun onManual(p: JSONObject) {
        val items = parseItems(p.optJSONArray("items"))
        if (items.isEmpty()) return
        repeatMode = p.optString("repeatMode", "off")
        shuffle = p.optBoolean("shuffle", false)
        startSession(
            Session(
                items = items,
                title = p.optString("title", items.first().title),
                source = "manual",
                eventId = null,
                priority = 2,
                volume = p.optDouble("volume", 1.0).toFloat(),
                maxDurationMs = 0,
                repeatsLeft = 0,
                startIndex = p.optInt("startIndex", 0).coerceIn(0, items.size - 1),
            ),
        )
    }

    private fun startSession(s: Session) {
        releasePlayer()
        session = s
        rebuildOrder(keepCurrent = false)
        stopAtElapsed = if (s.maxDurationMs > 0) SystemClock.elapsedRealtime() + s.maxDurationMs else 0L
        if (!requestFocus(s)) {
            Scheduler.setLastError(this, "Fokus audio ditolak (panggilan aktif?)")
            if (s.source == "scheduled") Scheduler.recordHistory(this, s.eventId, s.title, "skipped", "audio focus denied")
            session = null
            startNextPendingOrStop()
            return
        }
        handler.removeCallbacks(ticker)
        handler.post(ticker)
        playCurrent()
    }

    private fun rebuildOrder(keepCurrent: Boolean) {
        val s = session ?: return
        val current = order.getOrNull(pos)
        order = s.items.indices.toMutableList()
        if (shuffle) order.shuffle()
        pos = if (keepCurrent && current != null) order.indexOf(current).coerceAtLeast(0)
        else if (shuffle) 0 else s.startIndex
    }

    private fun playCurrent() {
        val s = session ?: return
        val item = s.items.getOrNull(order.getOrNull(pos) ?: -1) ?: run {
            finishSession("completed")
            return
        }
        releasePlayer()
        if (!File(item.path).exists()) {
            Scheduler.setLastError(this, "Fail tiada: ${item.title}")
            advance(userInitiated = false)
            return
        }
        prepared = false
        val mp = MediaPlayer()
        player = mp
        val usage = if (s.source == "scheduled") AudioAttributes.USAGE_ALARM else AudioAttributes.USAGE_MEDIA
        mp.setAudioAttributes(
            AudioAttributes.Builder().setUsage(usage).setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build(),
        )
        mp.setWakeMode(applicationContext, PowerManager.PARTIAL_WAKE_LOCK)
        mp.setOnPreparedListener {
            prepared = true
            applyVolume()
            it.start()
            Scheduler.setLastPlayback(this, item.title)
            goForeground(s.title, item.title)
            emit()
        }
        mp.setOnCompletionListener { advance(userInitiated = false) }
        mp.setOnErrorListener { _, what, extra ->
            Scheduler.setLastError(this, "MediaPlayer $what/$extra: ${item.title}")
            advance(userInitiated = false)
            true
        }
        try {
            mp.setDataSource(item.path)
            mp.prepareAsync()
        } catch (t: Throwable) {
            Scheduler.setLastError(this, "Tidak dapat membuka ${item.title}: ${t.message}")
            advance(userInitiated = false)
        }
    }

    private fun advance(userInitiated: Boolean) {
        val s = session ?: return
        if (!userInitiated && s.source == "manual" && repeatMode == "one") {
            playCurrent()
            return
        }
        pos++
        if (pos >= order.size) {
            when {
                s.source == "manual" && repeatMode == "all" -> pos = 0
                s.source == "scheduled" && s.repeatsLeft > 0 -> {
                    s.repeatsLeft--
                    pos = 0
                }
                else -> {
                    finishSession("completed")
                    return
                }
            }
        }
        playCurrent()
    }

    private fun previous() {
        if (session == null) return
        if (prepared && (player?.currentPosition ?: 0) > 3000) {
            player?.seekTo(0)
            return
        }
        pos = (pos - 1).coerceAtLeast(0)
        playCurrent()
    }

    private fun pause() {
        if (prepared && player?.isPlaying == true) player?.pause()
        emit()
    }

    private fun resume() {
        if (prepared && player?.isPlaying == false) player?.start()
        pausedByFocus = false
        emit()
    }

    private fun finishSession(reason: String) {
        val s = session
        releasePlayer()
        handler.removeCallbacks(ticker)
        stopAtElapsed = 0
        session = null
        if (s != null && s.source == "scheduled") {
            val status = if (reason == "completed" || reason == "max_duration") "played" else reason
            Scheduler.recordHistory(this, s.eventId, s.title, status, reason)
        }
        startNextPendingOrStop()
    }

    private fun startNextPendingOrStop() {
        val next = pending.removeFirstOrNull()
        if (next != null) {
            startSession(next)
        } else {
            abandonFocus()
            stopIfIdle()
        }
        emit()
    }

    private fun stopIfIdle() {
        if (session != null) return
        stopForeground(STOP_FOREGROUND_REMOVE) // minSdk 24
        stopSelf()
    }

    private fun releasePlayer() {
        prepared = false
        player?.let {
            try {
                it.setOnCompletionListener(null)
                it.setOnErrorListener(null)
                it.reset()
                it.release()
            } catch (_: Throwable) {
            }
        }
        player = null
    }

    private fun applyVolume() {
        val v = (session?.volume ?: 1f) * (if (ducked) 0.3f else 1f)
        if (prepared) player?.setVolume(v, v)
    }

    // ---- Audio focus -------------------------------------------------------

    private fun requestFocus(s: Session): Boolean {
        val usage = if (s.source == "scheduled") AudioAttributes.USAGE_ALARM else AudioAttributes.USAGE_MEDIA
        return if (Build.VERSION.SDK_INT >= 26) {
            val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(AudioAttributes.Builder().setUsage(usage).setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build())
                .setOnAudioFocusChangeListener(this, handler)
                .build()
            focusRequest = req
            audioManager.requestAudioFocus(req) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        } else {
            @Suppress("DEPRECATION")
            audioManager.requestAudioFocus(
                this,
                if (s.source == "scheduled") AudioManager.STREAM_ALARM else AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN,
            ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
    }

    private fun abandonFocus() {
        if (Build.VERSION.SDK_INT >= 26) {
            focusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
            focusRequest = null
        } else {
            @Suppress("DEPRECATION")
            audioManager.abandonAudioFocus(this)
        }
    }

    override fun onAudioFocusChange(change: Int) {
        when (change) {
            AudioManager.AUDIOFOCUS_LOSS -> {
                pending.clear()
                finishSession("focus_lost")
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                if (player?.isPlaying == true) {
                    player?.pause()
                    pausedByFocus = true
                }
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                ducked = true
                applyVolume()
            }
            AudioManager.AUDIOFOCUS_GAIN -> {
                ducked = false
                applyVolume()
                if (pausedByFocus) resume()
            }
        }
        emit()
    }

    // ---- Notification & state ---------------------------------------------

    private fun actionIntent(action: String, code: Int): PendingIntent =
        PendingIntent.getService(
            this, code, Intent(this, PlaybackService::class.java).setAction(action),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

    @Suppress("DEPRECATION")
    private fun buildNotification(title: String, text: String): Notification {
        val playing = player?.isPlaying == true
        val stopLabel = Scheduler.options(this).optString("stopLabel", "Henti")
        val b = Notifications.builder(this, Notifications.CH_PLAYBACK)
            .setSmallIcon(R.drawable.ic_stat_azan)
            .setContentTitle(title)
            .setContentText(text)
            .setContentIntent(Notifications.contentIntent(this))
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .addAction(
                Notification.Action.Builder(
                    null, if (playing) "❚❚" else "▶",
                    actionIntent(if (playing) ACTION_PAUSE else ACTION_RESUME, 1),
                ).build(),
            )
            .addAction(Notification.Action.Builder(null, "⏭", actionIntent(ACTION_NEXT, 2)).build())
            .addAction(Notification.Action.Builder(null, stopLabel, actionIntent(ACTION_STOP, 3)).build())
        if (Build.VERSION.SDK_INT < 26) b.setPriority(Notification.PRIORITY_LOW)
        return b.build()
    }

    private fun goForeground(title: String, text: String) {
        val n = buildNotification(title, text)
        if (Build.VERSION.SDK_INT >= 29) {
            startForeground(NOTIF_ID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIF_ID, n)
        }
    }

    private fun emit() {
        val s = session
        if (s == null) {
            publish(idle)
            return
        }
        val idx = order.getOrNull(pos) ?: 0
        val p = player
        publish(
            mapOf(
                "state" to if (prepared && p?.isPlaying == true) "playing" else "paused",
                "title" to s.items.getOrNull(idx)?.title,
                "index" to pos,
                "count" to s.items.size,
                "positionMs" to (if (prepared) p?.currentPosition ?: 0 else 0),
                "durationMs" to (if (prepared) p?.duration ?: 0 else 0),
                "volume" to s.volume.toDouble(),
                "repeatMode" to repeatMode,
                "shuffle" to shuffle,
                "source" to s.source,
            ),
        )
    }

    override fun onDestroy() {
        handler.removeCallbacks(ticker)
        releasePlayer()
        abandonFocus()
        session = null
        pending.clear()
        running = false
        publish(idle)
        super.onDestroy()
    }
}
