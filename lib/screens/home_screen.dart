import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/trust_badge.dart';
import 'document_type_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo + Branding
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'PhotoID',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Free passport & ID photos.\nNever uploaded. 100% on your device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),

              // Primary CTA
              ElevatedButton.icon(
                onPressed: () => _navigateToDocType(context, isCamera: true),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take New Photo'),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Secondary CTA
              OutlinedButton.icon(
                onPressed: () => _navigateToDocType(context, isCamera: false),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload Existing Photo'),
              ),
              const Spacer(),

              // Trust badges
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TrustBadge(
                    icon: Icons.lock_outline,
                    label: '100% on-device',
                  ),
                  TrustBadge(
                    icon: Icons.bolt_outlined,
                    label: '30-second process',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const TrustBadge(
                icon: Icons.verified_outlined,
                label: 'Government compliant',
              ),
              const Spacer(),

              // Ad placeholder
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Center(
                  child: Text(
                    'Ad Space',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDocType(BuildContext context, {required bool isCamera}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentTypeScreen(useCamera: isCamera),
      ),
    );
  }
}
