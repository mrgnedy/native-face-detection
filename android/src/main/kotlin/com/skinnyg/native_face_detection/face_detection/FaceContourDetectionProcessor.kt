package com.skinnyg.native_face_detection.face_detection

import android.media.Image
import android.util.Log
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import com.skinnyg.native_face_detection.FaceImageModel
import com.skinnyg.native_face_detection.camerax.BaseImageAnalyzer
import com.skinnyg.native_face_detection.camerax.GraphicOverlay
import java.io.IOException

class FaceContourDetectionProcessor(
    private val view: GraphicOverlay,
    private val onSuccessCallback: ((FaceStatus, FaceImageModel?) -> Unit)
) :
    BaseImageAnalyzer<List<Face>>() {

    private val realTimeOpts = FaceDetectorOptions.Builder()
        .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
        .setContourMode(FaceDetectorOptions.CONTOUR_MODE_NONE)
        .build()

    private val detector = FaceDetection.getClient(realTimeOpts)

    override val graphicOverlay: GraphicOverlay
        get() = view

    override fun detectInImage(image: InputImage): Task<List<Face>> {
        Log.e("ImageStatusRot", "${image.rotationDegrees}")
        return detector.process(image)
    }

    override fun stop() {
        try {
            detector.close()
        } catch (e: IOException) {
            Log.e(TAG, "Exception thrown while trying to close Face Detector: $e")
        }
    }

    override fun onSuccess(
        detectedFaces: List<Face>,
        graphicOverlay: GraphicOverlay,
        image: Image,
        rotation: Int
    ) {
        graphicOverlay.clear()
        val faces = ArrayList<Face>(0)
        if (detectedFaces.isNotEmpty()) {
            detectedFaces.forEach { face ->
                val faceGraphic = FaceContourGraphic(
                    graphicOverlay, face, image.cropRect,
                ) { it -> onSuccessCallback(it, null) }
                graphicOverlay.add(faceGraphic)
                if (ensureFaceNotTilted(face)) faces.add(face)
            }
            graphicOverlay.postInvalidate()
        }
        if (faces.isNotEmpty()) {

            FaceImageModel(
                faces.first().boundingBox, image, rotation
            ).also {
                onSuccessCallback(FaceStatus.NO_FACE, it)
            }

        } else {
            onSuccessCallback(FaceStatus.NO_FACE, null)
            Log.e(TAG, "Face Detector failed.")
        }

    }

    override fun onFailure(e: Exception) {
        Log.e(TAG, "Face Detector failed. $e")
        onSuccessCallback(FaceStatus.NO_FACE, null)
    }

    private fun ensureFaceNotTilted(face: Face): Boolean {
        val notTiltedVertical =
            face.headEulerAngleX <= 10 && face.headEulerAngleX >= -10;
        val notTiltedHorizontal =
            face.headEulerAngleY <= 15 && face.headEulerAngleY >= -15;
        val notTiltedAngular =
            face.headEulerAngleZ <= 10 && face.headEulerAngleZ >= -10;
        return if (notTiltedHorizontal && notTiltedVertical && notTiltedAngular) {
            print("In range X: ${face.headEulerAngleZ}");
            true;
        } else {
            print(
                "Out of range: $notTiltedAngular -- $notTiltedHorizontal -- $notTiltedVertical "
            );
            false;
        }
    }


    companion object {
        private const val TAG = "FaceDetectorProcessor"
    }

}