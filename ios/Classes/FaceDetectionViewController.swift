
import Accelerate
import AVFoundation
import Flutter
import Foundation
import UIKit
import Vision

class FaceDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var onReceiveImage: (_ imageBytes: FlutterStandardTypedData) -> Void
    private var acceptedFaces: [FaceImageModel] = []
    public let captureSession = AVCaptureSession()
    private var image: CVPixelBuffer?
    private var faceBox: CGRect?
    private var quality: Float?
    public let dispatchQueue =
//    DispatchQueue.global( qos: .utility)
        DispatchQueue(label: "camera_frame_processing_queue", qos: .default)
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var drawings: [CAShapeLayer] = []
    public var timer: Timer!
    init(onReceiveImage: @escaping (_: FlutterStandardTypedData) -> Void) {
        self.onReceiveImage = onReceiveImage
        super.init(nibName: nil, bundle: nil)
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func UpdateTimer() {
        if self.acceptedFaces.count < 10 {return ;}
        DispatchQueue.main.async {
            guard let image = self.image else { return }
            guard let faceBox = self.faceBox else { return }

            guard let pngData = self.getImage(from: image, cropBy: faceBox) else { return }
//            self.acceptedFaces.sort {$0.quality > $1.quality}
            self.onReceiveImage(pngData)
            self.timer.invalidate()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        addCameraInput()
        showCameraFeed()
        getCameraFrames()
        print("Will run")

//        setUpImageView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.frame
    }

    func getImage(from pixelBuffer: CVPixelBuffer, cropBy box: CGRect) -> FlutterStandardTypedData? {
        let ciimage: CIImage = CIImage(cvPixelBuffer: pixelBuffer)
//        let faceRect = VNImageRectForNormalizedRect(box, Int(ciimage.extent.size.width), Int(ciimage.extent.size.height))
//        let croppedFace = ciimage.cropped(to: faceRect)
        let context: CIContext = CIContext(options: nil)
        let cgImage: CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
        let cropped = cropImage(image: cgImage, by: box)
        guard let imageData = UIImage(cgImage: cropped).pngData() else { return nil }
        return FlutterStandardTypedData(bytes: imageData)
    }

    private func cropImage(image: CGImage, by box: CGRect) -> CGImage {
        let width = box.height * CGFloat(image.width)
        let height = box.width * CGFloat(image.height)
        let y = (box.origin.x) * CGFloat(image.height)
        let x = (1 - box.origin.y) * CGFloat(image.width) - height

        let croppingRect = CGRect(x: x, y: y, width: width, height: height)
        let croppedImage = image.cropping(to: croppingRect)!
        return croppedImage
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        detectFace(in: frame)
    }

    private func addCameraInput() {
        var deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .builtInDualCamera]

        if #available(iOS 15.4, *) {
            deviceTypes.append(.builtInTrueDepthCamera)
            deviceTypes.append(.builtInLiDARDepthCamera)
        }

        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .front).devices.first else {
            fatalError("No back camera device found, please make sure to run SimpleLaneDetection in an iOS device and not a simulator")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        captureSession.addInput(cameraInput)
    }

    private func showCameraFeed() {
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    }

    private func getCameraFrames() {
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: dispatchQueue)
        captureSession.addOutput(videoDataOutput)
        guard let connection = videoDataOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else { return }

        connection.videoOrientation = .portrait
    }

    private func detectFace(in image: CVPixelBuffer) {
        if #available(iOS 13.0, *) {
            let faceDetectionRequest = VNDetectFaceCaptureQualityRequest(completionHandler: { (request: VNRequest, _: Error?) in

                DispatchQueue.main.async {
                    if let results = request.results as? [VNFaceObservation] {
                        if results.isEmpty {self.acceptedFaces.removeAll()}
                        self.handleFaceDetectionResults(results, imageBuffer: image)
                    } else {
                        self.clearDrawings()
                        print("No faces")
                        self.acceptedFaces.removeAll()
                    }
                }
            })
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
            try? imageRequestHandler.perform([faceDetectionRequest])
        } else {
            // Fallback on earlier versions
        }
    }

    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation], imageBuffer image: CVPixelBuffer) {
        clearDrawings()
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.flatMap({ (observedFace: VNFaceObservation) -> [CAShapeLayer] in
            let faceBoundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            var newDrawings = [CAShapeLayer]()

            if #available(iOS 15.1, *) {
                print("Angle Yaw: \(String(describing: observedFace.yaw))")
                print("Angle Pitch: \(String(describing: observedFace.pitch))")
                print("Angle Roll: \(String(describing: observedFace.roll))")
                print("Quality: \(String(describing: observedFace.faceCaptureQuality))")

                let roll = (observedFace.roll?.floatValue ?? 0.0)
                let rollIsAt90 = (roll - (Float.pi / 2)).magnitude < 0.17
                let yaw = (observedFace.yaw?.floatValue ?? 0.0).magnitude
                let yawIsAt0 = yaw < 0.2
                let pitch = (observedFace.pitch?.floatValue ?? 0.0).magnitude
                let pitchIsAt0 = pitch < 0.2
                if !rollIsAt90 || !yawIsAt0 || !pitchIsAt0 {
                    return newDrawings
                }
            }

            faceBox = observedFace.boundingBox
            if #available(iOS 14, *) {
                quality = observedFace.faceCaptureQuality?.magnitude ?? 0.0
            }

            newDrawings.append(faceBoundingBoxShape)
            if let landmarks = observedFace.landmarks {
                newDrawings = newDrawings + self.drawFaceFeatures(landmarks, screenBoundingBox: faceBoundingBoxOnScreen)
            }
            return newDrawings
        })
        facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox) })
        drawings = facesBoundingBoxes
        if !drawings.isEmpty {
            print("isNotEMpty")

            acceptedFaces.append(
                FaceImageModel(
                    faceBox: faceBox!,
//                    image: image,
                    quality: quality!)
            )

            self.image = image
        }
    }

    private func clearDrawings() {
        drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
        image = nil
    }

    private func drawFaceFeatures(_ landmarks: VNFaceLandmarks2D, screenBoundingBox: CGRect) -> [CAShapeLayer] {
        var faceFeaturesDrawings: [CAShapeLayer] = []
//        if let leftEye = landmarks.leftEye {
//            let eyeDrawing = drawEye(leftEye, screenBoundingBox: screenBoundingBox)
//            faceFeaturesDrawings.append(eyeDrawing)
//        }
//        if let rightEye = landmarks.rightEye {
//            let eyeDrawing = drawEye(rightEye, screenBoundingBox: screenBoundingBox)
//            faceFeaturesDrawings.append(eyeDrawing)
//        }

        // draw other face features here
        return faceFeaturesDrawings
    }

    private func drawEye(_ eye: VNFaceLandmarkRegion2D, screenBoundingBox: CGRect) -> CAShapeLayer {
        let eyePath = CGMutablePath()
        let eyePathPoints = eye.normalizedPoints
            .map({ eyePoint in
                CGPoint(
                    x: eyePoint.x * screenBoundingBox.width + screenBoundingBox.origin.y,
                    y: eyePoint.y * screenBoundingBox.height + screenBoundingBox.origin.x)
            })
        eyePath.addLines(between: eyePathPoints)
        eyePath.closeSubpath()
        let eyeDrawing = CAShapeLayer()
        eyeDrawing.path = eyePath
        eyeDrawing.fillColor = UIColor.clear.cgColor
        eyeDrawing.strokeColor = UIColor.green.cgColor

        return eyeDrawing
    }
}

struct FaceImageModel {
    let faceBox: CGRect
//    let image: CVPixelBuffer
    let quality: Float
}
