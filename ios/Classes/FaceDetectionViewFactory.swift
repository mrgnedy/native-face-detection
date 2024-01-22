//
//  FaceDetectionViewFactory.swift
//  native_face_detection
//
//  Created by ahmed gendy on 09/01/2024.
//

import Flutter
import UIKit

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var onReceiveImage: (_ imageBytes: FlutterStandardTypedData) -> Void
    init(messenger: FlutterBinaryMessenger, onReceiveImage: @escaping (_ imageBytes: FlutterStandardTypedData) -> Void) {
        self.messenger = messenger
        self.onReceiveImage = onReceiveImage
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger, onReceiveImage: onReceiveImage)
    }

    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class FLNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var onReceiveImage: (_ imageBytes: FlutterStandardTypedData) -> Void

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        onReceiveImage: @escaping (_ imageBytes: FlutterStandardTypedData) -> Void
    ) {
        self.onReceiveImage = onReceiveImage
        let _viewCtrler = FaceDetectionViewController(onReceiveImage: onReceiveImage)
      
            _viewCtrler.captureSession.startRunning()
        
            print("Recreate")
        _view = _viewCtrler.view

        super.init()
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView) {
        _view.backgroundColor = UIColor.blue
        let nativeLabel = UILabel()
        nativeLabel.text = "Native text from iOS"
        nativeLabel.textColor = UIColor.white
        nativeLabel.textAlignment = .center
        nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
        _view.addSubview(nativeLabel)
    }
}
