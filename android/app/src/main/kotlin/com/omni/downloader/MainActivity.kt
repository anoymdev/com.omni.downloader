package com.omni.downloader

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.omni.downloader/ytdlp"

    companion object {
        @JvmStatic private var mainHandler: Handler? = null
        @JvmStatic @Volatile private var progressChannel: MethodChannel? = null
        @JvmStatic @Volatile private var cancelRequested: Boolean = false

        /**
         * Called from Python (via Chaquopy `jclass`) inside yt-dlp's progress
         * hook. Relays the progress event to Flutter on the main thread.
         */
        @JvmStatic
        fun emitProgress(
            status: String,
            downloaded: Long,
            total: Long,
            speed: Double,
            phase: String,
        ) {
            val channel = progressChannel ?: return
            val handler = mainHandler ?: return
            val args = HashMap<String, Any>()
            args["status"] = status
            args["downloaded"] = downloaded
            args["total"] = total
            args["speed"] = speed
            args["phase"] = phase
            handler.post {
                try {
                    channel.invokeMethod("onProgress", args)
                } catch (_: Throwable) {}
            }
        }

        /** Checked by the Python progress hook; true => throw to abort. */
        @JvmStatic
        fun isCancelled(): Boolean = cancelRequested
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize Python runtime if not already started.
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }

        mainHandler = Handler(Looper.getMainLooper())
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        )
        progressChannel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "extractInfoJson" -> {
                    val videoUrl = call.argument<String>("videoUrl")!!
                    Thread {
                        try {
                            val py = Python.getInstance()
                            val module = py.getModule("ytdlp_bridge")
                            val json = module.callAttr(
                                "extract_info_json", videoUrl,
                            ).toString()
                            runOnUiThread { result.success(json) }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("PYTHON_ERROR", e.message, null)
                            }
                        }
                    }.start()
                }

                "resolveStreamUrl" -> {
                    val videoUrl = call.argument<String>("videoUrl")!!
                    val itag = call.argument<String>("itag")!!
                    Thread {
                        try {
                            val py = Python.getInstance()
                            val module = py.getModule("ytdlp_bridge")
                            val json = module.callAttr(
                                "resolve_stream_url", videoUrl, itag,
                            ).toString()
                            runOnUiThread { result.success(json) }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("PYTHON_ERROR", e.message, null)
                            }
                        }
                    }.start()
                }

                "resolveBestUrls" -> {
                    val videoUrl = call.argument<String>("videoUrl")!!
                    val videoItag = call.argument<String>("videoItag")!!
                    val audioItag = call.argument<String>("audioItag")
                    Thread {
                        try {
                            val py = Python.getInstance()
                            val module = py.getModule("ytdlp_bridge")
                            val json = module.callAttr(
                                "resolve_best_urls",
                                videoUrl, videoItag, audioItag,
                            ).toString()
                            runOnUiThread { result.success(json) }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("PYTHON_ERROR", e.message, null)
                            }
                        }
                    }.start()
                }

                "downloadStream" -> {
                    val videoUrl = call.argument<String>("videoUrl")!!
                    val itag = call.argument<String>("itag")!!
                    val outputTemplate =
                        call.argument<String>("outputTemplate")!!
                    val phase = call.argument<String>("phase") ?: ""
                    cancelRequested = false
                    Thread {
                        try {
                            val py = Python.getInstance()
                            val module = py.getModule("ytdlp_bridge")
                            val json = module.callAttr(
                                "download_stream",
                                videoUrl, itag, outputTemplate, phase,
                            ).toString()
                            runOnUiThread { result.success(json) }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("DOWNLOAD_ERROR", e.message, null)
                            }
                        }
                    }.start()
                }

                "cancelDownload" -> {
                    cancelRequested = true
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        progressChannel = null
        mainHandler = null
        super.onDestroy()
    }
}
