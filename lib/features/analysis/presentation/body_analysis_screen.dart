// VÍ DỤ cách dùng AsyncValue trong Widget.
//
// Tuân thủ:
//   - mobile-flutter #2: Widget chỉ hiển thị — logic ở Controller
//   - mobile-flutter #4: xử lý 3 trạng thái data/loading/error
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_states.dart';
import 'analysis_controller.dart';

class BodyAnalysisScreen extends ConsumerStatefulWidget {
  const BodyAnalysisScreen({super.key});

  @override
  ConsumerState<BodyAnalysisScreen> createState() => _BodyAnalysisScreenState();
}

class _BodyAnalysisScreenState extends ConsumerState<BodyAnalysisScreen> {
  bool _hasTriggeredHaptic = false;
  bool _isPicking = false;

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

    await ref
        .read(bodyAnalysisProvider.notifier)
        .analyzeImage(File(file.path));

    if (!context.mounted) return;
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

      final prevHadError = previous?.hasError ?? false;
      if (next.hasError && !prevHadError && context.mounted) {
        final message = _humanizeError(next.error!);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.isEmpty ? 'Đã có lỗi xảy ra.' : message)),
        );
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
          const SizedBox(height: AppSpacing.s24),
          Expanded(
            child: bodyState.when(
              loading: () => const AppLoading(),
              error: (error, _) => AppErrorState(
                message: _humanizeError(error),
              ),
              data: (result) {
                if (result == null) {
                  return Center(
                    child: Text(
                      'Vui lòng chụp/chọn ảnh toàn thân để bắt đầu.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shape: ${result.shape}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          result.explanation,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        const Text('Styling tips:'),
                        const SizedBox(height: AppSpacing.s8),
                        ...result.stylingTips.map((tip) => Text('• $tip')),
                        const SizedBox(height: AppSpacing.s16),
                        const Text('Nên tránh:'),
                        const SizedBox(height: AppSpacing.s8),
                        ...result.avoid.map((tip) => Text('• $tip')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
