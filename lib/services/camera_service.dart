import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    // Prefer front camera for selfie/ID photos
    final frontCamera = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
  }

  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    if (_controller!.value.isTakingPicture) return null;
    return _controller!.takePicture();
  }

  Future<void> startImageStream(
    void Function(CameraImage image) onImage,
  ) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.startImageStream(onImage);
  }

  Future<void> stopImageStream() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.stopImageStream();
    } catch (_) {
      // May already be stopped
    }
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
