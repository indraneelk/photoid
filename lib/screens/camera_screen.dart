import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/photo_spec.dart';
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
  late AnimationController _pulseController;

  // Simulated compliance checks (will be driven by ML Kit in production)
  final Map<String, CheckStatus> _checks = {
    'Face detected': CheckStatus.passing,
    'Head straight': CheckStatus.passing,
    'Move slightly closer': CheckStatus.warning,
    'Eyes open': CheckStatus.passing,
    'Neutral expression': CheckStatus.passing,
  };

  bool get _allPassing =>
      _checks.values.where((s) => s == CheckStatus.failing).isEmpty &&
      _checks.values.where((s) => s == CheckStatus.warning).isEmpty;

  bool get _canCapture =>
      _checks.values.where((s) => s == CheckStatus.passing).length >= 3;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
                  // Checks
                  ..._checks.entries.map((e) => ComplianceCheckItem(
                        label: e.key,
                        status: e.value,
                      )),
                  const SizedBox(height: AppSpacing.md),

                  // Capture button
                  _buildCaptureButton(),
                  const SizedBox(height: AppSpacing.sm),

                  // Hint text
                  Text(
                    _allPassing ? 'Ready! Tap to capture.' : 'Hold steady for best results',
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
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Placeholder for camera feed
          const Center(
            child: Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: Colors.white24,
            ),
          ),

          // Face guide oval
          CustomPaint(
            size: const Size(200, 260),
            painter: _FaceGuidePainter(
              isCompliant: _allPassing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = _canCapture
            ? 1.0 + (_pulseController.value * 0.04)
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: _canCapture ? _onCapture : null,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _canCapture ? AppColors.primary : Colors.grey.shade700,
                border: Border.all(
                  color: _canCapture ? AppColors.success : Colors.grey.shade600,
                  width: 4,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                color: _canCapture ? Colors.white : Colors.grey.shade500,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onCapture() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(spec: widget.spec),
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
      // Dashed effect for non-compliant
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
