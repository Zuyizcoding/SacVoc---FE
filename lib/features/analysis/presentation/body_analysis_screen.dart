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
import 'widgets/body_result_view.dart';

class BodyAnalysisScreen extends ConsumerStatefulWidget {
  const BodyAnalysisScreen({super.key});

  @override
  ConsumerState<BodyAnalysisScreen> createState() => _BodyAnalysisScreenState();
}

class _BodyAnalysisScreenState extends ConsumerState<BodyAnalysisScreen> {
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
        .read(bodyAnalysisProvider.notifier)
        .analyzeImage(_lastPickedFile!);
    if (!context.mounted) return;
  }

  Future<void> _retryLastAnalysis() async {
    final file = _lastPickedFile;
    if (file == null) return;
    await ref.read(bodyAnalysisProvider.notifier).analyzeImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final bodyState = ref.watch(bodyAnalysisProvider);
    final isBusy = _isPicking || bodyState.isLoading;

    ref.listen(bodyAnalysisProvider, (previous, next) {
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
      appBar: AppBar(title: const Text('Phân tích dáng người')),
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
                Text('Ảnh phù hợp cho F2',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Ưu tiên ảnh toàn thân, đứng thẳng, thấy rõ vai đến chân và để tay thả lỏng tự nhiên.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  'Tránh crop mất chân/đầu, góc chụp lệch mạnh hoặc mặc đồ quá rộng che tỷ lệ cơ thể.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          Expanded(
            child: bodyState.when(
              loading: () => const AppLoading(
                title: 'AI đang phân tích dáng người',
                icon: Icons.accessibility_new_rounded,
                messages: [
                  'Đang ước lượng tỷ lệ vai, eo và hông...',
                  'Đang suy ra dáng người phù hợp nhất...',
                  'Đang tạo gợi ý phối đồ và lưu hồ sơ dáng...',
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
                      'Vui lòng chụp/chọn ảnh toàn thân rõ dáng để bắt đầu.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return SingleChildScrollView(
                    child: BodyResultView(result: result));
              },
            ),
          ),
        ],
      ),
    );
  }
}
