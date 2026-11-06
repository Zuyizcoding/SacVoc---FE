import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../analysis/presentation/analysis_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(analysisHistoryProvider);
    final history = historyState.asData?.value;
    final hasColor = history?.color != null;
    final hasBody = history?.body != null;
    final isOutfitReady = hasColor && hasBody;
    final nextLabel = !hasColor
        ? 'Bắt đầu phân tích màu sắc'
        : !hasBody
            ? 'Tiếp tục phân tích dáng người'
            : 'Xem gợi ý trang phục';
    final nextRoute = !hasColor
        ? '/color'
        : !hasBody
            ? '/body'
            : '/outfit';
    final overview = !hasColor && !hasBody
        ? 'Bắt đầu với ảnh khuôn mặt và ảnh toàn thân để cá nhân hóa gợi ý trang phục.'
        : isOutfitReady
            ? 'Hồ sơ của bạn đã đủ dữ liệu để xem gợi ý trang phục phù hợp.'
            : 'Bạn đã có một phần hồ sơ. Hoàn thiện bước còn lại để nhận gợi ý trang phục tốt hơn.';

    return AppScaffold(
      appBar: AppBar(title: const Text('Sắc Vóc')),
      scroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hồ sơ phong cách',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  overview,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.s16),
                _ProfileSummaryRow(
                  icon: Icons.palette_outlined,
                  title: 'Màu sắc cá nhân',
                  subtitle: hasColor
                      ? 'Đã có kết quả màu sắc trong hồ sơ.'
                      : 'Chụp selfie rõ mặt để xác định mùa sắc.',
                  status: hasColor ? 'Đã lưu' : 'Chưa có',
                  isReady: hasColor,
                  onPressed: () => context.push('/color'),
                ),
                const SizedBox(height: 12),
                _ProfileSummaryRow(
                  icon: Icons.accessibility_new_outlined,
                  title: 'Dáng người',
                  subtitle: hasBody
                      ? 'Đã có kết quả dáng người trong hồ sơ.'
                      : 'Chụp ảnh toàn thân để hệ thống suy ra form phù hợp.',
                  status: hasBody ? 'Đã lưu' : 'Chưa có',
                  isReady: hasBody,
                  onPressed: () => context.push('/body'),
                ),
                const SizedBox(height: 12),
                _ProfileSummaryRow(
                  icon: Icons.checkroom_outlined,
                  title: 'Gợi ý outfit',
                  subtitle: isOutfitReady
                      ? 'Có thể xem ngay các outfit được cá nhân hóa theo hồ sơ.'
                      : 'Hoàn thiện màu sắc và dáng người để mở gợi ý chính xác hơn.',
                  status: isOutfitReady ? 'Sẵn sàng' : 'Cần bổ sung hồ sơ',
                  isReady: isOutfitReady,
                  onPressed: () => context.push('/outfit'),
                ),
                const SizedBox(height: AppSpacing.s16),
                AppPrimaryButton(
                  label: nextLabel,
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => context.push(nextRoute),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppSecondaryButton(
            label: 'Xem lại kết quả',
            onPressed: () => context.push('/history'),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tác vụ nhanh',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Bạn có thể cập nhật từng phần hồ sơ bất cứ lúc nào.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.s16),
                AppSecondaryButton(
                  label: 'Phân tích màu sắc',
                  onPressed: () => context.push('/color'),
                ),
                const SizedBox(height: 12),
                AppSecondaryButton(
                  label: 'Phân tích dáng người',
                  onPressed: () => context.push('/body'),
                ),
                const SizedBox(height: 12),
                AppSecondaryButton(
                  label: 'Gợi ý trang phục',
                  onPressed:
                      isOutfitReady ? () => context.push('/outfit') : null,
                ),
              ],
            ),
          ),
          if (historyState.isLoading) ...[
            const SizedBox(height: 12),
            Text(
              'Đang cập nhật hồ sơ của bạn...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileSummaryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final bool isReady;
  final VoidCallback onPressed;

  const _ProfileSummaryRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isReady,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: isReady
              ? colorScheme.primary.withValues(alpha: 0.25)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isReady
                ? colorScheme.primary.withValues(alpha: 0.12)
                : Colors.grey.shade200,
            child: Icon(
              icon,
              size: 18,
              color: isReady ? colorScheme.primary : Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.s4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  status,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isReady ? colorScheme.primary : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onPressed, child: const Text('Mở')),
        ],
      ),
    );
  }
}
