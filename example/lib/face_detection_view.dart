import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:native_face_detection/native_face_detection.dart';
import 'package:native_face_detection/native_face_detection_platform_interface.dart';
import 'package:native_face_detection/native_face_detection_view.dart';

class FacecDetectionView extends StatefulWidget {
  const FacecDetectionView({super.key, required this.onImage});
  final Function(Uint8List imageBytes) onImage;
  @override
  State<FacecDetectionView> createState() => _FacecDetectionViewState();
}

class _FacecDetectionViewState extends State<FacecDetectionView> {
  final _nativeFaceDetection = NativeFaceDetection();
  Uint8List list = Uint8List(0);

  @override
  void initState() {
    super.initState();
    _nativeFaceDetection.addMethodCallHandler("onFaceCaptured", (p0) {
      setState(() {
        list = p0;
        print("Received: ${list.length}");
      });
    });
    if(Platform.isAndroid) {
      _nativeFaceDetection.pushAndroidView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if(Platform.isIOS)
            const Positioned.fill(child: _NativeView()),
          if (list.isNotEmpty)
            Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.memory(
                  list,
                  gaplessPlayback: true,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            )
        ],
      ),
    );
  }
}
class _NativeView extends StatelessWidget {
  const _NativeView({super.key});
  String get viewType => NativeFaceDetectionPlatform.instance.viewId;
  @override
  Widget build(BuildContext context) {
    return UiKitView(viewType: viewType, layoutDirection: TextDirection.ltr);
  }
}