import Flutter
import UIKit

public class NativeFaceDetectionPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_face_detection", binaryMessenger: registrar.messenger())
        let instance = NativeFaceDetectionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let factory = FLNativeViewFactory(messenger: registrar.messenger()) { imageBytes in
            channel.invokeMethod("onFaceCaptured", arguments: imageBytes)
        }
        registrar.register(factory, withId: "com.skinnyg.native_face_detection/view")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

struct SendImageToNativeDelegate {
    let channel: FlutterMethodChannel
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
}
