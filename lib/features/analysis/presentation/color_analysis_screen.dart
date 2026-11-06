import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_states.dart';
import 'analysis_controller.dart';
import 'widgets/color_result_view.dart';

class ColorAnalysisScreen extends ConsumerStatefulWidget {
  const ColorAnalysisScreen({super.key});

  @override
  ConsumerState<ColorAnalysisScreen> createState() =>
      _ColorAnalysisScreenState();
}

class _ColorAnalysisScreenState extends ConsumerState<ColorAnalysisScreen> {
  bool _hasTriggeredHaptic = false;
  bool _isPicking = false;
  File? _lastPickedFile;

  String _humanizeError(Object error) {
    final raw = error.toString();
    return raw.replaceFirst('Exception: ', '').trim();
  }

  Future<void> _pickAndAnalyze(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 90);

    if (!mounted) return;
    setState(() => _isPicking = false);

    if (file == null) return;

    _lastPickedFile = File(file.path);
    await ref
        .read(colorAnalysisProvider.notifier)
        .analyzeImage(_lastPickedFile!);
    if (!context.mounted) return;
  }

  Future<void> _retryLastAnalysis() async {
    final file = _lastPickedFile;
    if (file == null) return;
    await ref.read(colorAnalysisProvider.notifier).analyzeImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final colorState = ref.watch(colorAnalysisProvider);
    final isBusy = _isPicking || colorState.isLoading;

    ref.listen(colorAnalysisProvider, (previous, next) {
      final hasData = next.asData?.value != null;
      if (hasData && !_hasTriggeredHaptic) {
        HapticFeedback.lightImpact();
        _hasTriggeredHaptic = true;
      }
      if (next.isLoading) {
        _hasTriggeredHaptic = false;
      }
    });

    return AppScaffold(
      appBar: AppBar(title: const Text('Phân tích màu sắc')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPrimaryButton(
            label: 'Chụp ảnh',
            icon: Icons.camera_alt_outlined,
            onPressed: isBusy
                ? null
                : () => _pickAndAnalyze(context, ref, ImageSource.camera),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppSecondaryButton(
            label: 'Chọn ảnh',
            icon: Icons.photo_library_outlined,
            onPressed: isBusy
                ? null
                : () => _pickAndAnalyze(context, ref, ImageSource.gallery),
          ),
          const SizedBox(height: AppSpacing.s8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ảnh phù hợp cho F1',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Ưu tiên selfie gần, thấy rõ khuôn mặt và vùng cổ, ánh sáng đều.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  'Tránh dùng ảnh toàn thân, chụp quá xa, ngược sáng hoặc che mặt bằng kính/phụ kiện.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          Expanded(
            child: colorState.when(
              loading: () => const AppLoading(
                title: 'AI đang phân tích màu sắc',
                icon: Icons.palette_outlined,
                messages: [
                  'Đang đọc undertone và độ tương phản khuôn mặt...',
                  'Đang đối chiếu nhóm mùa sắc phù hợp nhất...',
                  'Đang tổng hợp bảng màu và gợi ý menswear...',
                ],
              ),
              error: (error, _) => AppErrorState(
                message: _humanizeError(error),
                onRetry: _lastPickedFile == null ? null : _retryLastAnalysis,
              ),
              data: (result) {
                if (result == null) {
                  return Center(
                    child: Text(
                      'Vui lòng chụp/chọn ảnh selfie gần để bắt đầu phân tích màu sắc.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return SingleChildScrollView(
                    child: ColorResultView(result: result));
              },
            ),
          ),
        ],
      ),
    );
  }
}
