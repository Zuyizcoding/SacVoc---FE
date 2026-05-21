import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/figma_palette.dart';
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

    await ref.read(bodyAnalysisProvider.notifier).analyzeImage(File(file.path));
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
    });

    return AppScaffold(
      appBar: AppBar(title: const Text('Phân tích dáng người')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPrimaryButton(
            label: 'Chụp ảnh',
            icon: Icons.camera_alt_outlined,
            onPressed: isBusy ? null : () => _pickAndAnalyze(context, ref, ImageSource.camera),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppSecondaryButton(
            label: 'Chọn ảnh',
            icon: Icons.photo_library_outlined,
            onPressed: isBusy ? null : () => _pickAndAnalyze(context, ref, ImageSource.gallery),
          ),
          const SizedBox(height: AppSpacing.s8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ảnh phù hợp cho F2', style: Theme.of(context).textTheme.titleMedium),
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
              loading: () => const AppLoading(),
              error: (error, _) => AppErrorState(message: _humanizeError(error)),
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

                final theme = Theme.of(context);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gợi ý phối đồ', style: theme.textTheme.titleMedium),
                            const SizedBox(height: AppSpacing.s8),
                            ...result.stylingTips.map(
                              (tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('- $tip', style: theme.textTheme.bodyMedium),
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
                                child: Text('- $tip', style: theme.textTheme.bodyMedium),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
