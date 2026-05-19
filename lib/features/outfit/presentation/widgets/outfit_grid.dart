/// OutfitGrid — Lưới 6 outfit (2 cột × 3 hàng).
///
/// Tuân thủ:
///   - ui-ux-design #2: 8pt grid — spacing 16, borderRadius 16
///   - ui-ux-design #3: Bóng đổ mềm, nền #FAFAFA
///   - Tính năng #31: Hiển thị 6 outfit
///   - Tính năng #33: Nhấn vào → chi tiết + nút Shopee
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../outfit_controller.dart';
import '../../domain/outfit_result.dart';


class OutfitGrid extends ConsumerWidget {
  const OutfitGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitState = ref.watch(outfitControllerProvider);

    return outfitState.when(
      // ─── Loading: Placeholder list ───
      loading: () => _buildLoadingList(),

      // ─── Error: Thông báo tiếng Việt ───
      error: (error, _) => _buildErrorState(context, ref, error),

      // ─── Data: Lưới 6 outfit ───
      data: (result) {
        if (result == null) {
          return _buildEmptyState(context, ref);
        }
        if (result.outfits.isEmpty) {
          return const Center(
            child: Text('Chưa có dữ liệu trang phục. Vui lòng thử lại sau.'),
          );
        }
        return _buildList(context, result.outfits);
      },
    );
  }

  /// List 1 cột — đúng yêu cầu port Figma
  Widget _buildList(BuildContext context, List<OutfitItem> outfits) {
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: outfits.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s16),
      itemBuilder: (context, index) => _OutfitListItem(outfit: outfits[index]),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s16),
      itemBuilder: (_, __) => AppCard(
        child: Row(
          children: [
            Container(
              width: 88,
              height: 112,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(AppRadii.r16),
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, color: Colors.grey.shade200),
                  const SizedBox(height: AppSpacing.s8),
                  Container(height: 14, width: 180, color: Colors.grey.shade200),
                  const SizedBox(height: AppSpacing.s16),
                  Container(height: 12, width: 120, color: Colors.grey.shade200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error state — phân biệt MissingAnalysisException (Tính năng #15)
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    // Import MissingAnalysisException từ outfit_repository.dart
    final message = error.toString();

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.orange.shade300),
            const SizedBox(height: AppSpacing.s16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s24),
            FilledButton(
              onPressed: () {
                ref.read(outfitControllerProvider.notifier)
                   .loadRecommendations();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state — chưa tải data
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checkroom, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Nhấn bên dưới để xem gợi ý trang phục\nphù hợp với màu sắc và dáng người của bạn',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s24),
            FilledButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Xem gợi ý'),
              onPressed: () {
                ref.read(outfitControllerProvider.notifier)
                   .loadRecommendations();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OutfitListItem extends StatelessWidget {
  final OutfitItem outfit;

  const _OutfitListItem({required this.outfit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.r16),
      onTap: () => context.push('/outfit/${outfit.id}'),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.r16),
              child: CachedNetworkImage(
                imageUrl: outfit.imageUrl,
                width: 88,
                height: 112,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 88,
                  height: 112,
                  color: Colors.grey.shade200,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 88,
                  height: 112,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported, size: 24),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    outfit.priceRange,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8,
                      vertical: AppSpacing.s4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.10),
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                    ),
                    child: Text(
                      'Match ${(outfit.score * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
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
