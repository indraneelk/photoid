import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/photo_spec.dart';
import 'camera_screen.dart';

class DocumentTypeScreen extends StatefulWidget {
  final bool useCamera;

  const DocumentTypeScreen({super.key, required this.useCamera});

  @override
  State<DocumentTypeScreen> createState() => _DocumentTypeScreenState();
}

class _DocumentTypeScreenState extends State<DocumentTypeScreen> {
  String _searchQuery = '';

  List<PhotoSpec> get _filteredSpecs {
    if (_searchQuery.isEmpty) return PhotoSpec.popular;
    final q = _searchQuery.toLowerCase();
    return PhotoSpec.popular.where((spec) {
      return spec.country.toLowerCase().contains(q) ||
          spec.documentType.toLowerCase().contains(q) ||
          spec.countryCode.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Document Type'),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Search countries...',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          // Results
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _filteredSpecs.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final spec = _filteredSpecs[index];
                return _SpecTile(
                  spec: spec,
                  onTap: () => _selectSpec(spec),
                );
              },
            ),
          ),

          // Custom dimensions link
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextButton.icon(
              onPressed: () {
                // TODO: Custom dimensions screen
              },
              icon: const Icon(Icons.straighten_outlined, size: 18),
              label: const Text('Enter custom dimensions'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectSpec(PhotoSpec spec) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CameraScreen(spec: spec),
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  final PhotoSpec spec;
  final VoidCallback onTap;

  const _SpecTile({required this.spec, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Country code badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Text(
                  spec.countryCode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${spec.country} ${spec.documentType}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spec.dimensionLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
