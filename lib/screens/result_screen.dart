import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/photo_spec.dart';
import '../widgets/compliance_check_item.dart';
import 'print_guide_screen.dart';

enum OutputFormat { digital, print4, print6 }

class ResultScreen extends StatefulWidget {
  final PhotoSpec spec;

  const ResultScreen({super.key, required this.spec});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  OutputFormat _selectedFormat = OutputFormat.digital;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo + Compliance side by side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo preview
                  Expanded(
                    flex: 2,
                    child: AspectRatio(
                      aspectRatio: widget.spec.widthMm / widget.spec.heightMm,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Compliance checks
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Compliance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ComplianceCheckItem(
                          label: widget.spec.dimensionLabel,
                          status: CheckStatus.passing,
                        ),
                        const ComplianceCheckItem(
                          label: 'White background',
                          status: CheckStatus.passing,
                        ),
                        const ComplianceCheckItem(
                          label: 'Head size 55%',
                          status: CheckStatus.passing,
                        ),
                        const ComplianceCheckItem(
                          label: 'Centered',
                          status: CheckStatus.passing,
                        ),
                        const ComplianceCheckItem(
                          label: 'Eyes open',
                          status: CheckStatus.passing,
                        ),
                        const ComplianceCheckItem(
                          label: 'No digital alteration',
                          status: CheckStatus.passing,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Output format selection
              const Text(
                'Save As',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _FormatOption(
                label: 'Digital photo (JPEG)',
                subtitle: '${widget.spec.widthPx}x${widget.spec.heightPx}px at ${widget.spec.dpi} DPI',
                value: OutputFormat.digital,
                groupValue: _selectedFormat,
                onChanged: (v) => setState(() => _selectedFormat = v!),
              ),
              _FormatOption(
                label: 'Print-ready 4x6" (4 photos)',
                subtitle: 'For home printing or photo kiosk',
                value: OutputFormat.print4,
                groupValue: _selectedFormat,
                onChanged: (v) => setState(() => _selectedFormat = v!),
              ),
              _FormatOption(
                label: 'Print-ready 4x6" (6 photos)',
                subtitle: 'For home printing or photo kiosk',
                value: OutputFormat.print6,
                groupValue: _selectedFormat,
                onChanged: (v) => setState(() => _selectedFormat = v!),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Save button
              ElevatedButton.icon(
                onPressed: _savePhoto,
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Save to Gallery'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Secondary actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Share functionality
                    },
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share'),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PrintGuideScreen(spec: widget.spec),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('Print Guide'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo saved to gallery'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _FormatOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final OutputFormat value;
  final OutputFormat groupValue;
  final ValueChanged<OutputFormat?> onChanged;

  const _FormatOption({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<OutputFormat>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
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
}
