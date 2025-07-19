package com.example.jv_easy_pdf_viewer

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.ParcelFileDescriptor
import android.os.Process
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.FilenameFilter

class JvEasyPdfViewerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var instance: FlutterPlugin.FlutterPluginBinding? = null
    private var backgroundHandler: Handler? = null
    private val pluginLocker = Any()
    private val filePrefix = "FlutterJvEasyPdfViewerPlugin"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "easy_pdf_viewer_plugin")
        channel?.setMethodCallHandler(this)
        instance = flutterPluginBinding
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        synchronized(pluginLocker) {
            if (backgroundHandler == null) {
                val handlerThread = HandlerThread("flutterEasyPdfViewer", Process.THREAD_PRIORITY_BACKGROUND)
                handlerThread.start()
                backgroundHandler = Handler(handlerThread.looper)
            }
        }
        val mainThreadHandler = Handler()
        backgroundHandler?.post {
            when (call.method) {
                "getNumberOfPages" -> {
                    val filePath = call.argument<String>("filePath")
                    val clearCacheDir = call.argument<Boolean>("clearCacheDir") ?: false
                    val numResult = getNumberOfPages(filePath, clearCacheDir)
                    mainThreadHandler.post { result.success(numResult) }
                }
                "getPage" -> {
                    val filePath = call.argument<String>("filePath")
                    val pageNumber = call.argument<Int>("pageNumber") ?: 1
                    val pageRes = getPage(filePath, pageNumber)
                    mainThreadHandler.post { result.success(pageRes) }
                }
                "clearCacheDir" -> {
                    clearCacheDir()
                    mainThreadHandler.post { result.success(null) }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun clearCacheDir() {
        try {
            val directory = instance?.applicationContext?.cacheDir ?: return
            val myFilter = FilenameFilter { _, name ->
                name.lowercase().startsWith(filePrefix.lowercase())
            }
            val files = directory.listFiles(myFilter) ?: return
            for (file in files) {
                file.delete()
            }
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
    }

    @SuppressLint("DefaultLocale")
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private fun getNumberOfPages(filePath: String?, clearCacheDir: Boolean): String? {
        if (filePath == null) return null
        val pdf = File(filePath)
        try {
            if (clearCacheDir) {
                clearCacheDir()
            }
            val renderer = PdfRenderer(ParcelFileDescriptor.open(pdf, ParcelFileDescriptor.MODE_READ_ONLY))
            return try {
                val pageCount = renderer.pageCount
                String.format("%d", pageCount)
            } finally {
                renderer.close()
            }
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        return null
    }

    private fun getFileNameFromPath(name: String): String {
        var filePath = name.substring(name.lastIndexOf('/') + 1)
        filePath = filePath.substring(0, filePath.lastIndexOf('.'))
        return String.format("%s-%s", filePrefix, filePath)
    }

    private fun createTempPreview(bmp: Bitmap, name: String, page: Int): String? {
        val fileNameOnly = getFileNameFromPath(name)
        return try {
            val fileName = String.format("%s-%d.png", fileNameOnly, page)
            val file = File.createTempFile(fileName, null, instance?.applicationContext?.cacheDir)
            val out = FileOutputStream(file)
            bmp.compress(Bitmap.CompressFormat.PNG, 100, out)
            out.flush()
            out.close()
            file.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private fun getPage(filePath: String?, pageNumber: Int): String? {
        if (filePath == null) return null
        val pdf = File(filePath)
        try {
            val renderer = PdfRenderer(ParcelFileDescriptor.open(pdf, ParcelFileDescriptor.MODE_READ_ONLY))
            val pageCount = renderer.pageCount
            var pageNum = pageNumber
            if (pageNum > pageCount) {
                pageNum = pageCount
            }
            val page = renderer.openPage(--pageNum)
            var width = page.width.toDouble()
            var height = page.height.toDouble()
            val docRatio = width / height
            width = 2048.0
            height = width / docRatio
            val bitmap = Bitmap.createBitmap(width.toInt(), height.toInt(), Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            canvas.drawColor(Color.WHITE)
            page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
            return try {
                createTempPreview(bitmap, filePath, pageNum)
            } finally {
                page.close()
                renderer.close()
            }
        } catch (ex: Exception) {
            println(ex.message)
            ex.printStackTrace()
        }
        return null
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        instance = null
    }
} 