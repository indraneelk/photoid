import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/photo_spec.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final PhotoSpec spec;

  const ProcessingScreen({super.key, required this.spec});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final List<_ProcessingStep> _steps = [
    _ProcessingStep('Removing background', false),
    _ProcessingStep('Adjusting crop', false),
    _ProcessingStep('Checking compliance', false),
    _ProcessingStep('Finalizing', false),
  ];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _runProcessing();
  }

  Future<void> _runProcessing() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _steps[i].completed = true;
        _currentStep = i + 1;
      });
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(spec: widget.spec),
      ),
    );
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
                // Photo placeholder
                Container(
                  width: 120,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Processing steps
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
  bool completed;

  _ProcessingStep(this.label, this.completed);
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
