import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_face_detection_method_channel.dart';

abstract class NativeFaceDetectionPlatform extends PlatformInterface {
  /// Constructs a NativeFaceDetectionPlatform.
  NativeFaceDetectionPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeFaceDetectionPlatform _instance =
      MethodChannelNativeFaceDetection();

  /// The default instance of [NativeFaceDetectionPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeFaceDetection].
  static NativeFaceDetectionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeFaceDetectionPlatform] when
  /// they register themselves.
  static set instance(NativeFaceDetectionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  final String viewId='';
  addMethodCallHandler(String methodName, Function(dynamic) callback);
  pushAndroidView();
}
