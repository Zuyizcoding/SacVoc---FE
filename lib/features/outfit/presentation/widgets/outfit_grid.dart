/// OutfitGrid — Lưới 6 outfit (2 cột × 3 hàng).
///
/// Tuân thủ:
///   - ui-ux-design #2: 8pt grid — spacing 16, borderRadius 16
///   - ui-ux-design #3: Bóng đổ mềm, nền #FAFAFA
///   - Tính năng #31: Hiển thị 6 outfit
///   - Tính năng #33: Nhấn vào → chi tiết + nút Shopee
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../outfit_controller.dart';
import '../../domain/outfit_result.dart';
import '../../../../core/theme/app_theme.dart';


class OutfitGrid extends ConsumerWidget {
  const OutfitGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitState = ref.watch(outfitControllerProvider);

    return outfitState.when(
      // ─── Loading: Shimmer placeholder ───
      loading: () => _buildShimmerGrid(),

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
        return _buildGrid(context, result.outfits);
      },
    );
  }

  /// Lưới 2 cột — 8pt grid spacing
  Widget _buildGrid(BuildContext context, List<OutfitItem> outfits) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacing16,   // bội 8
        mainAxisSpacing: AppTheme.spacing16,     // bội 8
        childAspectRatio: 0.65,                  // ảnh dọc
      ),
      itemCount: outfits.length,
      itemBuilder: (context, index) => _OutfitCard(outfit: outfits[index]),
    );
  }

  /// Shimmer loading (Tính năng #31 — shimmer loading)
  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacing16,
        mainAxisSpacing: AppTheme.spacing16,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.orange.shade300),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacing24),
            ElevatedButton(
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
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checkroom, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Nhấn bên dưới để xem gợi ý trang phục\nphù hợp với màu sắc và dáng người của bạn',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacing24),
            ElevatedButton.icon(
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


/// Card cho 1 outfit trong grid
class _OutfitCard extends StatelessWidget {
  final OutfitItem outfit;

  const _OutfitCard({required this.outfit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate tới OutfitDetailScreen — Tính năng #32
        context.push('/outfit/${outfit.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          // Bóng đổ mềm (ui-ux-design #3)
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Ảnh outfit ───
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusMedium),
                ),
                child: Image.network(
                  outfit.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.image_not_supported, size: 32),
                  ),
                ),
              ),
            ),

            // ─── Info section ───
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên outfit (Body — SemiBold)
                  Text(
                    outfit.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Giá + match score (Caption — Light)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        outfit.priceRange,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(outfit.score * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
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
