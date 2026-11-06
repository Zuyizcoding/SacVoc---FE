import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_states.dart';
import '../domain/body_result.dart';
import '../domain/color_result.dart';
import 'analysis_controller.dart';
import 'widgets/body_result_view.dart';
import 'widgets/color_result_view.dart';

// Màn "Xem lại kết quả" — đọc history từ AnalysisHistory.
//

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
    Future.microtask(
        () => ref.read(analysisHistoryProvider.notifier).refresh());
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileSummaryCard(context, color: color, body: body),
                const SizedBox(height: AppSpacing.s16),
                if (color != null) ...[
                  ColorResultView(
                      result: color,
                      sourceNotice:
                          'Phân tích màu sắc gần nhất đang dùng chế độ dự phòng cho demo vì AI quá tải.'),
                  const SizedBox(height: AppSpacing.s24),
                ],
                if (body != null) ...[
                  BodyResultView(
                      result: body,
                      sourceNotice:
                          'Phân tích dáng người gần nhất đang dùng chế độ dự phòng cho demo vì AI quá tải.',
                      tipBullet: '•'),
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

  Widget _buildProfileSummaryCard(
    BuildContext context, {
    required ColorResult? color,
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
            body == null
                ? 'F2 dáng người: chưa có'
                : 'F2 dáng người: ${body.shape}',
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
}
