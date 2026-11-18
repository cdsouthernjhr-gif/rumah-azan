package com.rumahazan.app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import java.io.File

/**
 * Files shared to Rumah Azan from other apps ("Kongsi" / "Buka dengan").
 *
 * The sending app grants temporary read access to the content:// URIs, so no
 * storage permission is needed. Each file is copied into app-private cache
 * (cacheDir/incoming); Flutter then imports it as new or uses it to replace
 * an existing item, and deletes the cached copy.
 */
object IncomingFiles {
    private const val MAX_BYTES = 200L * 1024 * 1024
    private val ALLOWED = setOf("mp3", "m4a", "aac", "ogg", "opus", "wav", "flac", "jpg", "jpeg", "png", "webp")

    /** Content URIs carried by a SEND / SEND_MULTIPLE / VIEW intent. */
    fun urisFrom(intent: Intent?): List<Uri> {
        if (intent == null) return emptyList()
        // Re-launch from Recents redelivers the original intent: ignore it.
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return emptyList()
        return when (intent.action) {
            Intent.ACTION_SEND -> listOfNotNull(streamExtra(intent))
            Intent.ACTION_SEND_MULTIPLE -> streamListExtra(intent)
            Intent.ACTION_VIEW -> listOfNotNull(intent.data)
            else -> emptyList()
        }.filter { it.scheme == "content" || it.scheme == "file" }
    }

    @Suppress("DEPRECATION")
    private fun streamExtra(i: Intent): Uri? =
        if (Build.VERSION.SDK_INT >= 33) i.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        else i.getParcelableExtra(Intent.EXTRA_STREAM)

    @Suppress("DEPRECATION")
    private fun streamListExtra(i: Intent): List<Uri> =
        (if (Build.VERSION.SDK_INT >= 33) i.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)
        else i.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)) ?: emptyList()

    /**
     * Copies [uris] into cache. Call OFF the main thread. Returns one map per
     * file: path, name, mime, kind (audio|image) — or error for rejected ones.
     */
    fun copyToCache(ctx: Context, uris: List<Uri>): List<Map<String, Any?>> {
        val dir = File(ctx.cacheDir, "incoming").apply { mkdirs() }
        return uris.mapIndexed { idx, uri ->
            val name = displayName(ctx, uri) ?: "fail_$idx"
            val mime = ctx.contentResolver.getType(uri) ?: ""
            val ext = name.substringAfterLast('.', "").lowercase()
            val kind = when {
                mime.startsWith("audio/") -> "audio"
                mime.startsWith("image/") -> "image"
                ext in setOf("mp3", "m4a", "aac", "ogg", "opus", "wav", "flac") -> "audio"
                ext in setOf("jpg", "jpeg", "png", "webp") -> "image"
                else -> "other"
            }
            if (kind == "other" || ext !in ALLOWED) {
                return@mapIndexed mapOf("name" to name, "mime" to mime, "kind" to kind, "error" to "unsupported")
            }
            val safe = name.replace(Regex("[^\\w\\-. ]"), "_")
            val target = File(dir, "${System.currentTimeMillis()}_${idx}_$safe")
            try {
                var total = 0L
                ctx.contentResolver.openInputStream(uri).use { input ->
                    requireNotNull(input) { "cannot open" }
                    target.outputStream().use { out ->
                        val buf = ByteArray(64 * 1024)
                        while (true) {
                            val n = input.read(buf)
                            if (n < 0) break
                            total += n
                            if (total > MAX_BYTES) throw IllegalStateException("too large")
                            out.write(buf, 0, n)
                        }
                    }
                }
                mapOf("path" to target.absolutePath, "name" to name, "mime" to mime, "kind" to kind)
            } catch (t: Throwable) {
                target.delete()
                mapOf("name" to name, "mime" to mime, "kind" to kind, "error" to (t.message ?: t.javaClass.simpleName))
            }
        }
    }

    private fun displayName(ctx: Context, uri: Uri): String? {
        if (uri.scheme == "file") return uri.lastPathSegment
        return try {
            ctx.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c ->
                if (c.moveToFirst()) c.getString(0) else null
            }
        } catch (_: Exception) {
            null
        }
    }
}
