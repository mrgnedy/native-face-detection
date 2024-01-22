import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CapturedFaceScreen extends StatelessWidget {
  static const route = "captured-face";
  const CapturedFaceScreen({
    Key? key,
    required this.imageBytes,
  }) : super(key: key);

  final Uint8List imageBytes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.black,
            width: MediaQuery.sizeOf(context).width,
            child: Image.memory(
              imageBytes,
              height: MediaQuery.sizeOf(context).height / 2,
              fit: BoxFit.fitHeight,
            ),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height / 2,
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              children: [
                const Text("Are you satisfied with the quality of the image?"),
                ElevatedButton(
                  // onPressed: () => onAccept(state.imageBytes),
                  onPressed: () {},
                  child: const Text("Yes, Proceed"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Recapture"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
