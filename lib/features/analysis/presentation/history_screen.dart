// Màn "Xem lại kết quả" — đọc history từ AnalysisHistory.
//
// Tuân thủ:
//   - mobile-flutter #2: Widget chỉ hiển thị — logic ở Controller
//   - mobile-flutter #4: xử lý 3 trạng thái data/loading/error
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/figma_palette.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/color_palette_row.dart';
import '../../../core/widgets/confidence_indicator.dart';
import '../../../core/widgets/season_gradient_card.dart';
import 'analysis_controller.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure we always fetch the latest result when entering the screen.
    Future.microtask(() => ref.read(analysisHistoryProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(analysisHistoryProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Xem lại kết quả')),
      child: historyState.when(
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorState(
          message: error.toString(),
        ),
        data: (result) {
          final color = result?.color;
          final body = result?.body;

          if (color == null && body == null) {
            return Center(
              child: Text(
                'Chưa có lịch sử phân tích.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            );
          }

          final theme = Theme.of(context);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (color != null) ...[
                  SeasonGradientCard(
                    subSeason: color.subSeason,
                    primarySeason: color.primarySeason,
                    confidence: color.confidence,
                    explanation: color.explanation,
                    gradientFrom: _hexToColor(color.gradientFrom),
                    gradientTo: _hexToColor(color.gradientTo),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  ConfidenceIndicator(confidence: color.confidence),
                  const SizedBox(height: AppSpacing.s16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bảng màu cá nhân',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        ColorPaletteRow(hexColors: color.palette),
                        const SizedBox(height: AppSpacing.s16),
                        Text(
                          color.advice,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                ],
                if (body != null) ...[
                  // Match BodyAnalysisScreen structure
                  Container(
                    decoration: BoxDecoration(
                      gradient: FigmaPalette.ctaGradient,
                      borderRadius: BorderRadius.circular(AppRadii.r16),
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
                            body.shape,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          Text(
                            body.explanation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.90),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Styling tips', style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.s8),
                        ...body.stylingTips.map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $tip', style: theme.textTheme.bodyMedium),
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
                        ...body.avoid.map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $tip', style: theme.textTheme.bodyMedium),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
