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
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../analysis/domain/analysis_history_result.dart';
import '../../../analysis/presentation/analysis_controller.dart';
import '../outfit_controller.dart';
import '../../domain/outfit_result.dart';


class OutfitGrid extends ConsumerWidget {
  const OutfitGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitState = ref.watch(outfitControllerProvider);
    final history = ref.watch(analysisHistoryProvider).asData?.value;

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
        return _buildList(context, result, history);
      },
    );
  }

  /// List 1 cột — đúng yêu cầu port Figma
  Widget _buildList(
    BuildContext context,
    OutfitResult result,
    AnalysisHistoryResult? history,
  ) {
    final outfits = result.outfits;
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: outfits.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s16),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _OutfitContextCard(result: result, history: history);
        }
        return _OutfitListItem(outfit: outfits[index - 1]);
      },
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
      child: AppCard(
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
              AppSecondaryButton(
                label: 'Thử lại',
                onPressed: () {
                  ref.read(outfitControllerProvider.notifier).loadRecommendations();
                },
              ),
            ],
          ),
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
                  if (outfit.reasonTags.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s8),
                    Wrap(
                      spacing: AppSpacing.s8,
                      runSpacing: AppSpacing.s8,
                      children: outfit.reasonTags
                          .take(2)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s8,
                                vertical: AppSpacing.s4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(AppRadii.r8),
                              ),
                              child: Text(
                                _reasonLabel(tag),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
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
                          .withValues(alpha: 0.10),
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

  String _reasonLabel(String tag) => switch (tag) {
        'exact_season' => 'Khớp mùa sắc',
        'primary_season' => 'Hợp nhóm mùa',
        'exact_shape' => 'Khớp dáng người',
        'compatible_shape' => 'Hợp form cơ thể',
        'color_family_match' => 'Hợp bảng màu',
        'fit_match' => 'Fit dễ tôn dáng',
        'formality_match' => 'Đúng dịp sử dụng',
        'low_color_confidence' => 'Màu đang ở mức tham khảo',
        'low_body_confidence' => 'Dáng đang ở mức tham khảo',
        'low_color_photo_quality' => 'Ảnh màu chưa tối ưu',
        'low_body_photo_quality' => 'Ảnh dáng chưa tối ưu',
        _ => tag.replaceAll('_', ' '),
      };
}

class _OutfitContextCard extends StatelessWidget {
  final OutfitResult result;
  final AnalysisHistoryResult? history;

  const _OutfitContextCard({
    required this.result,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final color = history?.color;
    final body = history?.body;
    final degraded = (color?.analysisSource != null && color!.analysisSource != 'live') ||
        (body?.analysisSource != null && body!.analysisSource != 'live');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vì sao hệ thống gợi ý như vậy', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Dựa trên ${color?.subSeason ?? 'màu sắc'} + ${body?.shape ?? 'dáng người'} + dịp hằng ngày.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Truy vấn F3: ${result.queryUsed}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (result.querySource != null) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Nguồn vector: ${_querySourceLabel(result.querySource!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (degraded) ...[
            const SizedBox(height: 12),
            Text(
              'Lưu ý: một phần tín hiệu F1/F2 đang ở chế độ dự phòng cho demo, nên đây là gợi ý cá nhân hóa best-effort.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _querySourceLabel(String source) => switch (source) {
        'precomputed_query_vector' => 'precomputed demo vectors',
        'injected_encoder' => 'test/injected encoder',
        _ => source.replaceAll('_', ' '),
      };
}
