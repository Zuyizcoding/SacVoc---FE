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

import '../../../core/widgets/color_palette_row.dart';
import '../../../core/widgets/confidence_indicator.dart';
import '../../../core/widgets/season_gradient_card.dart';
import 'analysis_controller.dart';

class ColorAnalysisScreen extends ConsumerStatefulWidget {
  const ColorAnalysisScreen({super.key});

  @override
  ConsumerState<ColorAnalysisScreen> createState() =>
      _ColorAnalysisScreenState();
}

class _ColorAnalysisScreenState extends ConsumerState<ColorAnalysisScreen> {
  bool _hasTriggeredHaptic = false;

  Future<void> _pickAndAnalyze(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 90);

    if (file == null) return;

    await ref
        .read(colorAnalysisProvider.notifier)
        .analyzeImage(File(file.path));

    if (!context.mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final colorState = ref.watch(colorAnalysisProvider);

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

    return Scaffold(
      appBar: AppBar(title: const Text('Phân tích màu sắc')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickAndAnalyze(context, ref, ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Chụp ảnh'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _pickAndAnalyze(context, ref, ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Chọn ảnh'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: colorState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Lỗi: ${error.toString()}'),
                  ),
                  data: (result) {
                    if (result == null) {
                      return const Center(
                        child: Text('Vui lòng chụp/chọn ảnh selfie để bắt đầu.'),
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
                          const SizedBox(height: 16),
                          ConfidenceIndicator(
                            confidence: result.confidence,
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bảng màu cá nhân',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  ColorPaletteRow(hexColors: result.palette),
                                  const SizedBox(height: 16),
                                  Text(
                                    result.advice,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
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
