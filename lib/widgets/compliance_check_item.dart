import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CheckStatus { passing, warning, failing, pending }

class ComplianceCheckItem extends StatelessWidget {
  final String label;
  final CheckStatus status;

  const ComplianceCheckItem({
    super.key,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (status) {
      case CheckStatus.passing:
        return const Icon(Icons.check_circle, color: AppColors.success, size: 20);
      case CheckStatus.warning:
        return const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20);
      case CheckStatus.failing:
        return const Icon(Icons.cancel, color: AppColors.error, size: 20);
      case CheckStatus.pending:
        return Icon(Icons.radio_button_unchecked, color: AppColors.textMuted, size: 20);
    }
  }

  Color get _textColor {
    switch (status) {
      case CheckStatus.passing:
        return AppColors.textPrimary;
      case CheckStatus.warning:
        return AppColors.warning;
      case CheckStatus.failing:
        return AppColors.error;
      case CheckStatus.pending:
        return AppColors.textMuted;
    }
  }
}
