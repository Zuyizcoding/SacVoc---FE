import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/advice_summary_card.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/color_palette_row.dart';
import '../../../../core/widgets/confidence_indicator.dart';
import '../../../../core/widgets/menswear_guidance_card.dart';
import '../../../../core/widgets/season_gradient_card.dart';
import '../../domain/color_result.dart';
import 'analysis_source_banner.dart';

class ColorResultView extends StatelessWidget {
  final ColorResult result;
  final String sourceNotice;
  const ColorResultView(
      {super.key,
      required this.result,
      this.sourceNotice =
          'Kết quả này đang dùng chế độ dự phòng cho demo vì AI tạm thời quá tải. Hãy xem đây là mẫu tham khảo minh họa thay vì phân tích live hoàn toàn.'});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.analysisSource != 'live') ...[
          AnalysisSourceBanner(message: sourceNotice),
          const SizedBox(height: AppSpacing.s16),
        ],
        SeasonGradientCard(
          subSeason: result.subSeason,
          primarySeason: result.primarySeason,
          confidence: result.confidence,
          explanation: result.explanation,
          gradientFrom: _hexToColor(result.gradientFrom),
          gradientTo: _hexToColor(result.gradientTo),
        ),
        const SizedBox(height: AppSpacing.s16),
        ConfidenceIndicator(confidence: result.confidence),
        const SizedBox(height: AppSpacing.s16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bảng màu cá nhân',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s16),
              ColorPaletteRow(hexColors: result.palette),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        AdviceSummaryCard(
          title: 'Tóm tắt nhanh',
          advice: result.advice,
        ),
        if (result.menswear != null) ...[
          const SizedBox(height: AppSpacing.s16),
          MenswearGuidanceCard(guidance: result.menswear!),
        ],
      ],
    );
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
