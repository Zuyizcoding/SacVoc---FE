// Màn "Xem lại kết quả" — đọc history từ AnalysisHistory.
//
// Tuân thủ:
//   - mobile-flutter #2: Widget chỉ hiển thị — logic ở Controller
//   - mobile-flutter #4: xử lý 3 trạng thái data/loading/error
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Xem lại kết quả')),
      body: SafeArea(
        child: historyState.when(
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
          data: (result) {
            final color = result?.color;
            final body = result?.body;

            if (color == null && body == null) {
              return const Center(
                child: Text('Chưa có lịch sử phân tích.'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing16),
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
                    const SizedBox(height: AppTheme.spacing16),
                    ConfidenceIndicator(confidence: color.confidence),
                    const SizedBox(height: AppTheme.spacing16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bảng màu cá nhân',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            ColorPaletteRow(hexColors: color.palette),
                            const SizedBox(height: AppTheme.spacing16),
                            Text(
                              color.advice,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                  ],
                  if (body != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dáng người: ${body.shape}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            Text(
                              body.explanation,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            const Text('Styling tips:'),
                            const SizedBox(height: AppTheme.spacing8),
                            ...body.stylingTips.map((tip) => Text('• $tip')),
                            const SizedBox(height: AppTheme.spacing16),
                            const Text('Nên tránh:'),
                            const SizedBox(height: AppTheme.spacing8),
                            ...body.avoid.map((tip) => Text('• $tip')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
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
