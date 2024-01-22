package com.skinnyg.native_face_detection

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.RectF
import android.media.Image
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.camera.camera2.Camera2Config
import androidx.camera.core.CameraXConfig
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.graphics.toRect
import androidx.core.graphics.toRectF
import com.skinnyg.native_face_detection.camerax.CameraManager
import com.skinnyg.native_face_detection.camerax.YuvToRgbConverter
import com.skinnyg.native_face_detection.databinding.ActivityMainBinding
import com.skinnyg.native_face_detection.face_detection.FaceStatus
import io.flutter.embedding.android.FlutterActivity
import java.io.ByteArrayOutputStream

class FaceDetectionActivity : CameraXConfig.Provider,
    FlutterActivity() {

    private lateinit var cameraManager: CameraManager
    private lateinit var binding: ActivityMainBinding
    private var imageBytes: ByteArray? = null
    private var imagesCount = 0
    private var faceImageModel: FaceImageModel? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        createCameraManager()
        checkForPermission()
        onClicks()
//        val mainHandler = Handler(Looper.getMainLooper())
//
//        mainHandler.post(object : Runnable {
//            override fun run() {
//                processFaceImage()
//                println("Timer")
//                mainHandler.postDelayed(this, 200)
//            }
//        })
//        fixedRateTimer(
//            daemon = false,
//            initialDelay = 0,
//            period = 60 * 1000,
//            action = {
//
//            })
    }

    private fun checkForPermission() {
        if (allPermissionsGranted()) {
            cameraManager.startCamera()
        } else {
            ActivityCompat.requestPermissions(
                this, REQUIRED_PERMISSIONS, REQUEST_CODE_PERMISSIONS
            )
        }
    }

    private fun onClicks() {
        binding.btnSwitch.setOnClickListener {
            val intent = Intent()
            intent.putExtra("bytes", imageBytes)
            setResult(RESULT_OK, intent)
            finish()
//            cameraManager.changeCameraSelector()
        }
//        finishActivity(0);
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_PERMISSIONS) {
            if (allPermissionsGranted()) {
                cameraManager.startCamera()
            } else {
                Toast.makeText(this, "Permissions not granted by the user.", Toast.LENGTH_SHORT)
                    .show()
                finish()
            }
        }
    }

    private fun createCameraManager() {
        cameraManager = CameraManager(
            this, binding.previewViewFinder, this, binding.graphicOverlayFinder, ::processPicture
        )
    }


    private fun processPicture(faceStatus: FaceStatus, faceImage: FaceImageModel?) {
        faceImageModel = faceImage
//        if(faceImage == null) imagesCount = 0
        val image = processFaceImage();
        image?.let {
            intent.putExtra("bytes", it)
            println("Got data: ${intent?.extras?.getByteArray("bytes")}")
            setResult(RESULT_OK, intent)
            ImageBytesHolder.instance?.data = it
            finish()
        }
        Log.e("facestatus", "This is it ${faceStatus.name}")

//       when(faceStatus){}
    }

    private fun processFaceImage(): ByteArray? {
        faceImageModel?.let {
            imagesCount++;
            if(imagesCount < 10) return null;
            val image = it.image;
            val bitmapImage = Bitmap.createBitmap(
                image.width, image.height, Bitmap.Config.ARGB_8888
            )

            println("Bytes: before ${bitmapImage.byteCount}")

            YuvToRgbConverter(baseContext).yuvToRgb(
                image, bitmapImage
            )
            val matrix = Matrix().apply { postRotate(it.rotation.toFloat()) }
            val boxF = RectF();
            matrix.mapRect(boxF, it.faceBox.toRectF())
            val revMatrix = Matrix().apply { postRotate(-it.rotation.toFloat()) }
            revMatrix.mapRect(boxF, it.faceBox.toRectF())
            val box = boxF.toRect()
            val rotatedBmp = try {
                Bitmap.createBitmap(
                    bitmapImage,
                    (box.left + image.width).coerceIn(5, image.width - 5),
                    box.top.coerceIn(5, image.height - 5),
                    box.width(),
                    box.height(),
                    matrix,
                    false
                )
            } catch (e: Exception) {
                null
            }

            rotatedBmp?.let {
                binding.imageView.setImageBitmap(rotatedBmp);
                val stream = ByteArrayOutputStream();
                rotatedBmp.compress(Bitmap.CompressFormat.JPEG, 70, stream)
                val byteArray = stream.toByteArray()
                println("Bytes: after  ${byteArray.size}")
                return byteArray
            }

        }?: run {
//            imagesCount=0
        }
        return null;
    }

    private fun allPermissionsGranted() = REQUIRED_PERMISSIONS.all {
        ContextCompat.checkSelfPermission(baseContext, it) == PackageManager.PERMISSION_GRANTED
    }

    companion object {
        private const val REQUEST_CODE_PERMISSIONS = 10
        const val ACTIVITY_REQUEST_CODE = 111
        private val REQUIRED_PERMISSIONS = arrayOf(android.Manifest.permission.CAMERA)
    }

    override fun getCameraXConfig(): CameraXConfig {
        return Camera2Config.defaultConfig()
    }

}

data class FaceImageModel(
    val faceBox: Rect,
    val image: Image,
    val rotation: Int
)