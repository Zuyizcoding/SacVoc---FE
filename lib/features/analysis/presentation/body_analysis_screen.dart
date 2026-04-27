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

import 'analysis_controller.dart';

class BodyAnalysisScreen extends ConsumerStatefulWidget {
  const BodyAnalysisScreen({super.key});

  @override
  ConsumerState<BodyAnalysisScreen> createState() => _BodyAnalysisScreenState();
}

class _BodyAnalysisScreenState extends ConsumerState<BodyAnalysisScreen> {
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
        .read(bodyAnalysisProvider.notifier)
        .analyzeImage(File(file.path));

    if (!context.mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final bodyState = ref.watch(bodyAnalysisProvider);

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

    return Scaffold(
      appBar: AppBar(title: const Text('Phân tích dáng người')),
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
                child: bodyState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Lỗi: ${error.toString()}'),
                  ),
                  data: (result) {
                    if (result == null) {
                      return const Center(
                        child: Text('Vui lòng chụp/chọn ảnh toàn thân để bắt đầu.'),
                      );
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shape: ${result.shape}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text('Styling tips:'),
                            const SizedBox(height: 8),
                            ...result.stylingTips.map(
                              (tip) => Text('• $tip'),
                            ),
                          ],
                        ),
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
}
