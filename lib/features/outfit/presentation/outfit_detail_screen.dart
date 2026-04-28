import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import 'outfit_controller.dart';

class OutfitDetailScreen extends ConsumerWidget {
  final int outfitId;

  const OutfitDetailScreen({
    super.key,
    required this.outfitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(outfitDetailProvider(outfitId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết trang phục')),
      body: SafeArea(
        child: detailState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Text(
                'Lỗi: ${error.toString()}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (detail) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: Image.network(
                    detail.imageUrl,
                    height: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 280,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  detail.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Category: ${detail.category}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Giá: ${detail.priceRange}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing16),
                if (detail.explanation != null && detail.explanation!.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      child: Text(
                        detail.explanation!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                const SizedBox(height: AppTheme.spacing16),
                ElevatedButton.icon(
                  onPressed: detail.shopeeUrl.isEmpty
                      ? null
                      : () => _launchUrl(detail.shopeeUrl),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Mua trên Shopee'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
