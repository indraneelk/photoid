import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';

class ComplianceResult {
  final bool faceDetected;
  final bool headStraight;
  final bool properDistance;
  final bool eyesOpen;
  final bool neutralExpression;
  final String? distanceHint;

  ComplianceResult({
    required this.faceDetected,
    required this.headStraight,
    required this.properDistance,
    required this.eyesOpen,
    required this.neutralExpression,
    this.distanceHint,
  });

  bool get allPassing =>
      faceDetected &&
      headStraight &&
      properDistance &&
      eyesOpen &&
      neutralExpression;

  int get passingCount => [
        faceDetected,
        headStraight,
        properDistance,
        eyesOpen,
        neutralExpression,
      ].where((b) => b).length;

  static ComplianceResult get empty => ComplianceResult(
        faceDetected: false,
        headStraight: false,
        properDistance: false,
        eyesOpen: false,
        neutralExpression: false,
      );
}

class FaceDetectionService {
  late final FaceDetector _detector;
  bool _isProcessing = false;

  FaceDetectionService() {
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  Future<ComplianceResult> processImage(CameraImage image, CameraDescription camera) async {
    if (_isProcessing) return ComplianceResult.empty;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image, camera);
      if (inputImage == null) return ComplianceResult.empty;

      final faces = await _detector.processImage(inputImage);

      if (faces.isEmpty) {
        return ComplianceResult(
          faceDetected: false,
          headStraight: false,
          properDistance: false,
          eyesOpen: false,
          neutralExpression: false,
        );
      }

      final face = faces.first;
      return _evaluateCompliance(face, image.width, image.height);
    } catch (e) {
      debugPrint('Face detection error: $e');
      return ComplianceResult.empty;
    } finally {
      _isProcessing = false;
    }
  }

  ComplianceResult _evaluateCompliance(Face face, int imageWidth, int imageHeight) {
    // Head straight: check euler angles
    final headY = face.headEulerAngleY ?? 0; // yaw (left-right)
    final headZ = face.headEulerAngleZ ?? 0; // roll (tilt)
    final headStraight = headY.abs() < 10 && headZ.abs() < 8;

    // Proper distance: face should be 30-60% of frame height
    final faceHeight = face.boundingBox.height;
    final faceRatio = faceHeight / imageHeight;
    final properDistance = faceRatio > 0.25 && faceRatio < 0.65;

    String? distanceHint;
    if (faceRatio <= 0.25) {
      distanceHint = 'Move closer';
    } else if (faceRatio >= 0.65) {
      distanceHint = 'Move back';
    }

    // Eyes open
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
    final eyesOpen = leftEyeOpen > 0.6 && rightEyeOpen > 0.6;

    // Neutral expression (low smile probability = neutral)
    final smileProb = face.smilingProbability ?? 0.0;
    final neutralExpression = smileProb < 0.4;

    return ComplianceResult(
      faceDetected: true,
      headStraight: headStraight,
      properDistance: properDistance,
      eyesOpen: eyesOpen,
      neutralExpression: neutralExpression,
      distanceHint: distanceHint,
    );
  }

  InputImage? _convertCameraImage(CameraImage image, CameraDescription camera) {
    final rotation = _rotationFromCamera(camera);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    return InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  InputImageRotation? _rotationFromCamera(CameraDescription camera) {
    final orientations = {
      0: InputImageRotation.rotation0deg,
      90: InputImageRotation.rotation90deg,
      180: InputImageRotation.rotation180deg,
      270: InputImageRotation.rotation270deg,
    };
    return orientations[camera.sensorOrientation];
  }

  void dispose() {
    _detector.close();
  }
}
