import 'package:flutter_test/flutter_test.dart';
import 'package:native_face_detection/native_face_detection.dart';
import 'package:native_face_detection/native_face_detection_platform_interface.dart';
import 'package:native_face_detection/native_face_detection_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeFaceDetectionPlatform
    with MockPlatformInterfaceMixin
    implements NativeFaceDetectionPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  addMethodCallHandler(String methodName, Function(dynamic) callback) {
    // TODO: implement addMethodCallHandler
    throw UnimplementedError();
  }
  @override
  pushAndroidView() {
    // TODO: implement pushAndroidView
    throw UnimplementedError();
  }
  @override
  // TODO: implement viewId
  String get viewId => throw UnimplementedError();
}

void main() {
  final NativeFaceDetectionPlatform initialPlatform = NativeFaceDetectionPlatform.instance;

  test('$MethodChannelNativeFaceDetection is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeFaceDetection>());
  });

  test('getPlatformVersion', () async {
    NativeFaceDetection nativeFaceDetectionPlugin = NativeFaceDetection();
    MockNativeFaceDetectionPlatform fakePlatform = MockNativeFaceDetectionPlatform();
    NativeFaceDetectionPlatform.instance = fakePlatform;

    expect(await nativeFaceDetectionPlugin.getPlatformVersion(), '42');
  });
}
