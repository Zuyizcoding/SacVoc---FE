// Màn "Xem lại kết quả" — đọc history từ AnalysisHistory.
//
// Tuân thủ:
//   - mobile-flutter #2: Widget chỉ hiển thị — logic ở Controller
//   - mobile-flutter #4: xử lý 3 trạng thái data/loading/error
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/figma_palette.dart';
import '../../../core/widgets/advice_summary_card.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/color_palette_row.dart';
import '../../../core/widgets/confidence_indicator.dart';
import '../../../core/widgets/menswear_guidance_card.dart';
import '../../../core/widgets/season_gradient_card.dart';
import '../domain/body_result.dart';
import 'analysis_controller.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _humanizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

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
      appBar: AppBar(title: const Text('Hồ sơ phong cách')),
      child: historyState.when(
        loading: () => const AppLoading(
          title: 'Đang tải hồ sơ phong cách',
          icon: Icons.history_toggle_off_rounded,
          messages: [
            'Đang lấy lại kết quả màu sắc gần nhất...',
            'Đang lấy lại kết quả dáng người gần nhất...',
          ],
        ),
        error: (error, _) => AppErrorState(
          message: _humanizeError(error),
          onRetry: () => ref.read(analysisHistoryProvider.notifier).refresh(),
        ),
        data: (result) {
          final color = result?.color;
          final body = result?.body;

          if (color == null && body == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chưa có lịch sử phân tích.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  AppPrimaryButton(
                    label: 'Bắt đầu với F1 màu sắc',
                    onPressed: () => context.push('/color'),
                  ),
                ],
              ),
            );
          }

          final theme = Theme.of(context);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileSummaryCard(context, color: color, body: body),
                const SizedBox(height: AppSpacing.s16),
                if (color != null) ...[
                  if (color.analysisSource != 'live') ...[
                    _buildAnalysisSourceBanner(
                      context,
                      message:
                          'Phân tích màu sắc gần nhất đang dùng chế độ dự phòng cho demo vì AI quá tải.',
                    ),
                    const SizedBox(height: AppSpacing.s16),
                  ],
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  AdviceSummaryCard(
                    title: 'Tóm tắt nhanh',
                    advice: color.advice,
                  ),
                  if (color.menswear != null) ...[
                    const SizedBox(height: AppSpacing.s16),
                    MenswearGuidanceCard(guidance: color.menswear!),
                  ],
                  const SizedBox(height: AppSpacing.s24),
                ],
                if (body != null) ...[
                  if (body.analysisSource != 'live') ...[
                    _buildAnalysisSourceBanner(
                      context,
                      message:
                          'Phân tích dáng người gần nhất đang dùng chế độ dự phòng cho demo vì AI quá tải.',
                    ),
                    const SizedBox(height: AppSpacing.s16),
                  ],
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
                  ConfidenceIndicator(
                    confidence: body.confidence,
                    label: 'Độ chắc chắn phân tích dáng',
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  _buildPhotoQualityCard(context, body),
                  const SizedBox(height: AppSpacing.s16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gợi ý phối đồ', style: theme.textTheme.titleMedium),
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
                if (color != null && body != null) ...[
                  const SizedBox(height: AppSpacing.s24),
                  AppPrimaryButton(
                    label: 'Xem gợi ý outfit',
                    icon: Icons.auto_awesome,
                    onPressed: () => context.push('/outfit'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildPhotoQualityCard(BuildContext context, BodyResult result) {
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

  Widget _buildAnalysisSourceBanner(
    BuildContext context, {
    required String message,
  }) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.wifi_tethering_error_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard(
    BuildContext context, {
    required dynamic color,
    required BodyResult? body,
  }) {
    final theme = Theme.of(context);
    final readyForOutfit = color != null && body != null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tóm tắt hồ sơ', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s8),
          Text(
            color == null
                ? 'F1 màu sắc: chưa có'
                : 'F1 màu sắc: ${color.subSeason}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            body == null ? 'F2 dáng người: chưa có' : 'F2 dáng người: ${body.shape}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            readyForOutfit
                ? 'F3 đã sẵn sàng để tạo gợi ý outfit cá nhân hóa.'
                : 'Hoàn thành cả F1 và F2 để mở gợi ý outfit cá nhân hóa.',
            style: theme.textTheme.bodySmall,
          ),
        ],
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
