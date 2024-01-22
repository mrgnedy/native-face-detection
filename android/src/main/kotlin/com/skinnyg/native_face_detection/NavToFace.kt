//package com.skinnyg.native_face_detection
//
//import android.content.Intent
//import android.os.Bundle
//import com.google.android.material.snackbar.Snackbar
//import androidx.appcompat.app.AppCompatActivity
//import androidx.navigation.findNavController
//import androidx.navigation.ui.AppBarConfiguration
//import androidx.navigation.ui.navigateUp
//import androidx.navigation.ui.setupActionBarWithNavController
//import com.skinnyg.native_face_detection.databinding.ActivityNavToFaceBinding
//import io.flutter.embedding.android.FlutterActivity
//
//class NavToFace : FlutterActivity() {
//
//    private lateinit var appBarConfiguration: AppBarConfiguration
//    private lateinit var binding: ActivityNavToFaceBinding
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//
////        binding = ActivityNavToFaceBinding.inflate(R.layout.activity_nav_to_face)
//        setContentView(R.layout.activity_nav_to_face)
//
//
//
//         navBtn.setOnClickListener { view ->
//
//             val intent = Intent(this, FaceDetectionActivity().javaClass)
//            startActivityForResult(intent, 1)
//        }
//    }
//
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//        println("Got data ${intent.data}")
//    }
//
//
//}