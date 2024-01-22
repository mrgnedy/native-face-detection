import 'native_face_detection_platform_interface.dart';

class NativeFaceDetection {
  Future<String?> getPlatformVersion() {
    return NativeFaceDetectionPlatform.instance.getPlatformVersion();
  }
  String get viewId => NativeFaceDetectionPlatform.instance.viewId;
  addMethodCallHandler(String methodName, Function(dynamic) callback) {
    return NativeFaceDetectionPlatform.instance
        .addMethodCallHandler(methodName, callback);
  }

  pushAndroidView()=>NativeFaceDetectionPlatform.instance.pushAndroidView();
}
