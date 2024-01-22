package com.skinnyg.native_face_detection_example

import android.app.Activity
import android.content.Intent
import com.skinnyg.native_face_detection.FaceDetectionActivity
 import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var methodChannel: MethodChannel
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "native_face_detection")
        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "capture") {
                println("cap cap")
                val act = FaceDetectionActivity()
                val intent = Intent(this, act.javaClass)
                startActivityForResult(intent, FaceDetectionActivity.ACTIVITY_REQUEST_CODE)
//                result.success("Done")
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        println("Activity Result")
        if (resultCode == Activity.RESULT_OK) {
            methodChannel.invokeMethod("onFaceCaptured", data?.extras?.getByteArray("bytes"))
            println("Got data: ${data?.extras?.getByteArray("bytes")}")
            println("Got data: ${data?.extras}")
        }
    }
}
