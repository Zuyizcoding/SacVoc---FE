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
import '../../../core/widgets/color_palette_row.dart';
import '../../../core/widgets/confidence_indicator.dart';
import '../../../core/widgets/season_gradient_card.dart';
import 'analysis_controller.dart';

class ColorAnalysisScreen extends ConsumerStatefulWidget {
  const ColorAnalysisScreen({super.key});

  @override
  ConsumerState<ColorAnalysisScreen> createState() => _ColorAnalysisScreenState();
}

class _ColorAnalysisScreenState extends ConsumerState<ColorAnalysisScreen> {
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

    await ref.read(colorAnalysisProvider.notifier).analyzeImage(File(file.path));
    if (!context.mounted) return;
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
      appBar: AppBar(title: const Text('Phân tích màu sắc')),
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
          Text(
            'Mẹo: Ảnh nhỏ vẫn phân tích được. Để kết quả ổn định hơn, hãy chụp selfie sáng và rõ khuôn mặt.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.s24),
          Expanded(
            child: colorState.when(
              loading: () => const AppLoading(),
              error: (error, _) => AppErrorState(message: _humanizeError(error)),
              data: (result) {
                if (result == null) {
                  return Center(
                    child: Text(
                      'Vui lòng chụp/chọn ảnh selfie để bắt đầu.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                            Text('Bảng màu cá nhân', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: AppSpacing.s16),
                            ColorPaletteRow(hexColors: result.palette),
                            const SizedBox(height: AppSpacing.s16),
                            Text(result.advice, style: Theme.of(context).textTheme.bodyMedium),
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

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
