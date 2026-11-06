import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_states.dart';
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

    return AppScaffold(
      appBar: AppBar(title: const Text('Chi tiết trang phục')),
      scroll: true,
      child: detailState.when(
        loading: () => const SizedBox(
          height: 400,
          child: AppLoading(
            title: 'Đang tải chi tiết outfit',
            icon: Icons.checkroom_outlined,
          ),
        ),
        error: (error, _) => Padding(
          padding: AppSpacing.pagePadding,
          child: AppErrorState(
            message: error.toString().replaceFirst('Exception: ', ''),
            onRetry: () => ref.refresh(outfitDetailProvider(outfitId)),
          ),
        ),
        data: (detail) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: CachedNetworkImage(
                imageUrl: detail.imageUrl,
                height: 280,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 280,
                  color: Colors.grey.shade200,
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 280,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported, size: 48),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              detail.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Loại: ${_categoryLabel(detail.category)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Giá: ${detail.priceRange}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s16),
            if (detail.explanation != null && detail.explanation!.isNotEmpty)
              AppCard(
                child: Text(
                  detail.explanation!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: AppSpacing.s16),
            FilledButton.icon(
              onPressed: detail.shopeeUrl.isEmpty
                  ? null
                  : () => _launchUrl(detail.shopeeUrl),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Mua trên Shopee'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _categoryLabel(String category) => switch (category) {
        'top' => 'Áo',
        'bottom' => 'Quần',
        'set' => 'Set đồ',
        'outerwear' => 'Áo khoác',
        'footwear' => 'Giày',
        'accessory' => 'Phụ kiện',
        _ => category,
      };
}
