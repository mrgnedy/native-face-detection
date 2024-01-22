import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_face_detection_platform_interface.dart';

/// An implementation of [NativeFaceDetectionPlatform] that uses method channels.
class MethodChannelNativeFaceDetection extends NativeFaceDetectionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_face_detection');
  final Map<String, Function(dynamic args)> methodHandlers = {};

  Future setMethodCallHandler() async {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onFaceCaptured":
          debugPrint("Detected: ${call.arguments.runtimeType}");
          return Future.value(true);
        case "capture":
          debugPrint("Detected: ${call.arguments.runtimeType}");
          return Future.value(true);
        default:
          debugPrint("Unsupported method call: ${call.method}");
          return Future.value(false);
      }

      // return Future.value();
    });
  }

  @override
  // TODO: implement viewId
  String get viewId => "com.skinnyg.native_face_detection/view";

  @override
  addMethodCallHandler(String methodName, Function(dynamic) callback) {
    methodHandlers[methodName] = callback;
    methodChannel.setMethodCallHandler((call) {
      if (methodHandlers[call.method] != null) {
        methodHandlers[call.method]!(call.arguments);
        return Future.value(true);
      } else {
        debugPrint("Unsupported methodCall: ${call.method}");
        return Future.value(false);
      }
    });
  }

  pushAndroidView() async {
    await methodChannel.invokeMethod("capture");
  }


  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
