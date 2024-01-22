package com.skinnyg.native_face_detection

import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

/** NativeFaceDetectionPlugin */
class NativeFaceDetectionPlugin : FlutterPlugin {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var methodChannel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(
            binding.binaryMessenger, "native_face_detection"
        )
        methodChannel.setMethodCallHandler { call, _ ->
            ImageBytesHolder.instance?.onSet = { bytes -> setImage(bytes) }
            if (call.method == "capture") {
                val intent = Intent(binding.applicationContext, FaceDetectionActivity().javaClass)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                binding.applicationContext.startActivity(intent)
            }

        }


    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    private fun setImage(imageBytes: ByteArray) {
        methodChannel.invokeMethod("onFaceCaptured", imageBytes)
    }

}


class ImageBytesHolder private constructor() {
    var data: ByteArray? = null
        set(value) {
            Log.e("setImage", "on")
            value?.let { bytes ->
                onSet?.invoke(bytes)
            }
            field = value
        }

    var onSet: ((ByteArray) -> Unit)? = null


    companion object {
        var instance: ImageBytesHolder? = null
            get() {
                if (field == null) {
                    field = ImageBytesHolder()
                }
                return field
            }
    }
}