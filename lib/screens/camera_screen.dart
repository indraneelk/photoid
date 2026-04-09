import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/photo_spec.dart';
import '../services/camera_service.dart';
import '../services/face_detection_service.dart';
import '../widgets/compliance_check_item.dart';
import 'processing_screen.dart';

class CameraScreen extends StatefulWidget {
  final PhotoSpec spec;

  const CameraScreen({super.key, required this.spec});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  final FaceDetectionService _faceService = FaceDetectionService();
  late AnimationController _pulseController;

  ComplianceResult _compliance = ComplianceResult.empty;
  bool _isReady = false;
  int _allPassingFrames = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _initCamera();
  }

  Future<void> _initCamera() async {
    await _cameraService.initialize();
    if (!mounted) return;

    setState(() => _isReady = _cameraService.isInitialized);

    if (_cameraService.isInitialized) {
      _startDetection();
    }
  }

  void _startDetection() {
    final cameras = _cameraService.controller!.description;
    _cameraService.startImageStream((image) async {
      final result = await _faceService.processImage(image, cameras);
      if (!mounted) return;
      setState(() {
        _compliance = result;
        if (result.allPassing) {
          _allPassingFrames++;
        } else {
          _allPassingFrames = 0;
        }
      });

      // Auto-capture after 30 frames (~1 second) of all passing
      if (_allPassingFrames >= 30) {
        _allPassingFrames = 0;
        _onCapture();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cameraService.dispose();
    _faceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${widget.spec.country} ${widget.spec.documentType}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Camera viewfinder
            Expanded(
              flex: 3,
              child: _buildViewfinder(),
            ),

            // Compliance checklist
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ComplianceCheckItem(
                    label: 'Face detected',
                    status: _compliance.faceDetected
                        ? CheckStatus.passing
                        : CheckStatus.failing,
                  ),
                  ComplianceCheckItem(
                    label: 'Head straight',
                    status: _compliance.faceDetected
                        ? (_compliance.headStraight
                            ? CheckStatus.passing
                            : CheckStatus.warning)
                        : CheckStatus.pending,
                  ),
                  ComplianceCheckItem(
                    label: _compliance.distanceHint ?? 'Proper distance',
                    status: _compliance.faceDetected
                        ? (_compliance.properDistance
                            ? CheckStatus.passing
                            : CheckStatus.warning)
                        : CheckStatus.pending,
                  ),
                  ComplianceCheckItem(
                    label: 'Eyes open',
                    status: _compliance.faceDetected
                        ? (_compliance.eyesOpen
                            ? CheckStatus.passing
                            : CheckStatus.warning)
                        : CheckStatus.pending,
                  ),
                  ComplianceCheckItem(
                    label: 'Neutral expression',
                    status: _compliance.faceDetected
                        ? (_compliance.neutralExpression
                            ? CheckStatus.passing
                            : CheckStatus.warning)
                        : CheckStatus.pending,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildCaptureButton(),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _compliance.allPassing
                        ? 'Ready! Tap to capture.'
                        : 'Hold steady for best results',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewfinder() {
    if (!_isReady) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Camera preview
          Positioned.fill(
            child: CameraPreview(_cameraService.controller!),
          ),

          // Face guide oval
          CustomPaint(
            size: const Size(200, 260),
            painter: _FaceGuidePainter(
              isCompliant: _compliance.allPassing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    final canCapture = _compliance.passingCount >= 3;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = canCapture ? 1.0 + (_pulseController.value * 0.04) : 1.0;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: canCapture ? _onCapture : null,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: canCapture ? AppColors.primary : Colors.grey.shade700,
                border: Border.all(
                  color: canCapture ? AppColors.success : Colors.grey.shade600,
                  width: 4,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                color: canCapture ? Colors.white : Colors.grey.shade500,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onCapture() async {
    // Stop stream before capture
    await _cameraService.stopImageStream();
    HapticFeedback.mediumImpact();

    final photo = await _cameraService.takePicture();
    if (photo == null || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          spec: widget.spec,
          imagePath: photo.path,
        ),
      ),
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  final bool isCompliant;

  _FaceGuidePainter({required this.isCompliant});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCompliant
          ? AppColors.success.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    if (!isCompliant) {
      paint.strokeCap = StrokeCap.round;
      const dashWidth = 8.0;
      const dashSpace = 6.0;
      final path = Path()
        ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

      final pathMetrics = path.computeMetrics();
      for (final metric in pathMetrics) {
        double distance = 0;
        while (distance < metric.length) {
          final end = (distance + dashWidth).clamp(0, metric.length);
          canvas.drawPath(
            metric.extractPath(distance, end.toDouble()),
            paint,
          );
          distance += dashWidth + dashSpace;
        }
      }
    } else {
      canvas.drawOval(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FaceGuidePainter oldDelegate) {
    return oldDelegate.isCompliant != isCompliant;
  }
}
