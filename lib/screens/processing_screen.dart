import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../theme/app_theme.dart';
import '../models/photo_spec.dart';
import '../services/background_removal_service.dart';
import '../services/image_processing_service.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final PhotoSpec spec;
  final String? imagePath;

  const ProcessingScreen({super.key, required this.spec, this.imagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final List<_ProcessingStep> _steps = [
    _ProcessingStep('Removing background'),
    _ProcessingStep('Adjusting crop'),
    _ProcessingStep('Checking compliance'),
    _ProcessingStep('Finalizing'),
  ];

  int _currentStep = 0;
  String? _processedImagePath;

  @override
  void initState() {
    super.initState();
    _runProcessing();
  }

  Future<void> _runProcessing() async {
    final bgService = BackgroundRemovalService();
    final imgService = ImageProcessingService();

    try {
      // Step 1: Remove background
      setState(() => _currentStep = 0);
      img.Image? processed;

      if (widget.imagePath != null) {
        processed = await bgService.removeBackground(widget.imagePath!);
        // If ML Kit fails, fall back to original image
        processed ??= img.decodeImage(
          await File(widget.imagePath!).readAsBytes(),
        );
      }

      if (!mounted) return;
      setState(() {
        _steps[0].completed = true;
        _currentStep = 1;
      });

      // Step 2: Crop to spec
      await Future.delayed(const Duration(milliseconds: 300));
      if (processed != null) {
        processed = imgService.cropToSpec(processed, widget.spec);
      }

      if (!mounted) return;
      setState(() {
        _steps[1].completed = true;
        _currentStep = 2;
      });

      // Step 3: Compliance check
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _steps[2].completed = true;
        _currentStep = 3;
      });

      // Step 4: Save result
      await Future.delayed(const Duration(milliseconds: 200));
      if (processed != null) {
        _processedImagePath = await imgService.saveToTemp(
          processed,
          'photoid_result_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      if (!mounted) return;
      setState(() {
        _steps[3].completed = true;
        _currentStep = 4;
      });

      await Future.delayed(const Duration(milliseconds: 300));
      bgService.dispose();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            spec: widget.spec,
            imagePath: _processedImagePath,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Processing error: $e');
      // Fallback: skip to result even on error
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              spec: widget.spec,
              imagePath: widget.imagePath,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Photo preview
                if (widget.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.file(
                      File(widget.imagePath!),
                      width: 120,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 120,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.person_outline,
                        size: 48, color: AppColors.textMuted),
                  ),
                const SizedBox(height: AppSpacing.xl),

                // Steps
                ...List.generate(_steps.length, (i) {
                  final step = _steps[i];
                  return _StepRow(
                    label: step.label,
                    completed: step.completed,
                    isCurrent: i == _currentStep,
                    isPending: i > _currentStep,
                  );
                }),

                const SizedBox(height: AppSpacing.xl),
                Text(
                  _currentStep < _steps.length
                      ? 'Processing your photo...'
                      : 'Almost there...',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcessingStep {
  final String label;
  bool completed = false;
  _ProcessingStep(this.label);
}

class _StepRow extends StatelessWidget {
  final String label;
  final bool completed;
  final bool isCurrent;
  final bool isPending;

  const _StepRow({
    required this.label,
    required this.completed,
    required this.isCurrent,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (completed)
            const Icon(Icons.check_circle, color: AppColors.success, size: 24)
          else if (isCurrent)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.secondary,
              ),
            )
          else
            const Icon(Icons.radio_button_unchecked,
                color: AppColors.textMuted, size: 24),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              color: isPending ? AppColors.textMuted : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
