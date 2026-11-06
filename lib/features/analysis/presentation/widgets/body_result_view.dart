import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/figma_palette.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/confidence_indicator.dart';
import '../../domain/body_result.dart';
import 'analysis_source_banner.dart';
import 'photo_quality_card.dart';

class BodyResultView extends StatelessWidget {
  final BodyResult result;
  final String sourceNotice;
  final String tipBullet;
  const BodyResultView(
      {super.key,
      required this.result,
      this.sourceNotice =
          'Dáng người này đang được hiển thị từ chế độ dự phòng cho demo do AI quá tải. Hệ thống vẫn tiếp tục luồng trải nghiệm nhưng bạn nên hiểu đây không phải kết quả live hoàn toàn.',
      this.tipBullet = '-'});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.analysisSource != 'live') ...[
          AnalysisSourceBanner(message: sourceNotice),
          const SizedBox(height: AppSpacing.s16),
        ],
        Container(
          decoration: BoxDecoration(
            gradient: FigmaPalette.ctaGradient,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowTint(0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dáng người',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  result.shape,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  result.explanation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.90),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        ConfidenceIndicator(
          confidence: result.confidence,
          label: 'Độ chắc chắn phân tích dáng',
        ),
        const SizedBox(height: AppSpacing.s16),
        PhotoQualityCard(result: result),
        const SizedBox(height: AppSpacing.s16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gợi ý phối đồ', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s8),
              ...result.stylingTips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('$tipBullet $tip',
                      style: theme.textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nên tránh', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s8),
              ...result.avoid.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('$tipBullet $tip',
                      style: theme.textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
