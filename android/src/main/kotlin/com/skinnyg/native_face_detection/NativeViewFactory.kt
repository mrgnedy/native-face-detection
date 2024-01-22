//package com.skinnyg.native_face_detection
//
//import android.content.Context
//import android.content.pm.PackageManager
//import android.graphics.Bitmap
//import android.graphics.Matrix
//import android.graphics.Rect
//import android.graphics.RectF
//import android.media.Image
//import android.os.Bundle
//import android.util.Log
//import android.view.LayoutInflater
//import android.view.View
//import android.widget.ImageView
//import android.widget.Toast
//import androidx.appcompat.app.AppCompatActivity
//import androidx.core.app.ActivityCompat
//import androidx.core.content.ContextCompat
//import androidx.core.graphics.toRect
//import androidx.core.graphics.toRectF
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.android.FlutterView
//import io.flutter.plugin.common.StandardMessageCodec
//import io.flutter.plugin.platform.PlatformView
//import io.flutter.plugin.platform.PlatformViewFactory
//import java.io.ByteArrayOutputStream
//
//class NativeViewFactory: PlatformViewFactory(StandardMessageCodec.INSTANCE) {
//    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
//
//        val creationParams = args as Map<String?, Any?>?
//        return NativeView(context, viewId, creationParams)
//    }
//}
//
//
//internal class NativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
//
//    override fun getView(): View {
//        LayoutInflater.from(MainActivity()). inflate(R.layout., null);
//        return view;
//         createDefaultIntent(MainActivity())
//        start
//        var mainActivity = MainActivity();
//        var s = this@mainActivity;
//    return mainActivity.onCreateView()
//    }
//
//    override fun dispose() {}
//
//    init {
//    }
//}
//
//
//class MainActivity : AppCompatActivity() {
//
//    private lateinit var cameraManager: CameraManager
//    lateinit var imageView: ImageView
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        setContentView(R.layout.activity_main)
//        imageView = findViewById<ImageView>(R.id.imageView)
//        createCameraManager()
//        checkForPermission()
//        onClicks()
//    }
//
//    private fun checkForPermission() {
//        if (allPermissionsGranted()) {
//            cameraManager.startCamera()
//        } else {
//            ActivityCompat.requestPermissions(
//                this, REQUIRED_PERMISSIONS, REQUEST_CODE_PERMISSIONS
//            )
//        }
//    }
//
//    private fun onClicks() {
//        btnSwitch.setOnClickListener {
//            cameraManager.changeCameraSelector()
//        }
//    }
//
//    override fun onRequestPermissionsResult(
//        requestCode: Int, permissions: Array<String>, grantResults: IntArray
//    ) {
//        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
//        if (requestCode == REQUEST_CODE_PERMISSIONS) {
//            if (allPermissionsGranted()) {
//                cameraManager.startCamera()
//            } else {
//                Toast.makeText(this, "Permissions not granted by the user.", Toast.LENGTH_SHORT)
//                    .show()
//                finish()
//            }
//        }
//    }
//
//    private fun createCameraManager() {
//        cameraManager = CameraManager(
//            this, previewView_finder, this, graphicOverlay_finder, ::processPicture
//        )
//    }
//
//
//    private fun processPicture(faceStatus: FaceStatus, faceImage: FaceImageModel?) {
//
//        faceImage?.let {
//            val image = it.image;
//            val bitmapImage = Bitmap.createBitmap(
//                image.width, image.height, Bitmap.Config.ARGB_8888
//            )
//
//            println("Bytes: before ${bitmapImage.byteCount}")
//
//            YuvToRgbConverter(baseContext).yuvToRgb(
//                image, bitmapImage
//            )
//            val matrix = Matrix().apply { postRotate(it.rotation.toFloat()) }
//            val boxF = RectF();
//            matrix.mapRect(boxF, it.faceBox.toRectF())
//            val revMatrix = Matrix().apply { postRotate(-it.rotation.toFloat()) }
//            revMatrix.mapRect(boxF, it.faceBox.toRectF())
//            val box = boxF.toRect()
//            val rotatedBmp = try {
//                Bitmap.createBitmap(
//                    bitmapImage,
//                    (box.left + image.width).coerceIn(5, image.width - 5),
//                    box.top.coerceIn(5, image.height - 5),
//                    box.width(),
//                    box.height(),
//                    matrix,
//                    false
//                )
//            } catch (e: Exception) {
//                null
//            }
//
////                val x = box.left.coerceIn(0, (it.width + 100))
////                val y = box.top.coerceIn(0, (it.height + 100))
////                val x2 = box.width()
////                val y2 = box.height()
////                val croppedBmp = Bitmap.createBitmap(rotatedBmp, x, y, x2, y2)
//            rotatedBmp?.let {
//                imageView.setImageBitmap(rotatedBmp);
//
//                val stream = ByteArrayOutputStream();
//                rotatedBmp.compress(Bitmap.CompressFormat.JPEG, 70, stream)
//                val byteArray = stream.toByteArray()
//
//                println("Bytes: after  ${byteArray.size}")
//            }
//
//        }
//
//        Log.e("facestatus", "This is it ${faceStatus.name}")
//
////       when(faceStatus){}
//    }
//
//    private fun allPermissionsGranted() = REQUIRED_PERMISSIONS.all {
//        ContextCompat.checkSelfPermission(baseContext, it) == PackageManager.PERMISSION_GRANTED
//    }
//
//    companion object {
//        private const val REQUEST_CODE_PERMISSIONS = 10
//        private val REQUIRED_PERMISSIONS = arrayOf(android.Manifest.permission.CAMERA)
//    }
//
//}
//
//data class FaceImageModel(
//    val faceBox: Rect, val image: Image, val rotation: Int
//)