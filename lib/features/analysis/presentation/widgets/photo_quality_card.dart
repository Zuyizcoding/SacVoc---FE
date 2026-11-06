import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/body_result.dart';

class PhotoQualityCard extends StatelessWidget {
  final BodyResult result;
  const PhotoQualityCard({super.key, required this.result});
  String _qualityBandLabel(String? band) {
    switch ((band ?? '').toLowerCase()) {
      case 'excellent':
        return 'Rất tốt';
      case 'good':
        return 'Tốt';
      case 'usable':
        return 'Dùng được';
      case 'poor':
        return 'Thấp';
      default:
        return 'Chưa có dữ liệu';
    }
  }

  String _qualitySummary(BodyResult result) {
    switch ((result.photoQualityBand ?? '').toLowerCase()) {
      case 'excellent':
        return 'Ảnh đầu vào rất tốt, nên kết quả thường ổn định hơn.';
      case 'good':
        return 'Ảnh đủ tốt để dùng tự tin trong demo và tham khảo styling.';
      case 'usable':
        return 'Ảnh ở mức dùng được; hệ thống vẫn phân tích best-effort và kết quả nên được xem như tham khảo tốt.';
      case 'poor':
        return 'Ảnh vẫn được phân tích best-effort, nhưng bạn chỉ nên chụp lại nếu muốn tăng độ chính xác.';
      default:
        return 'Hệ thống không ghi nhận đủ metadata chất lượng cho ảnh này.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scorePercent = result.photoQualityScore == null
        ? null
        : (result.photoQualityScore! * 100).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chất lượng ảnh đầu vào', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Mức chất lượng: ${_qualityBandLabel(result.photoQualityBand)}',
            style: theme.textTheme.bodyMedium,
          ),
          if (scorePercent != null) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Điểm heuristic: $scorePercent%',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.s8),
          Text(
            _qualitySummary(result),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
