// VÍ DỤ cách dùng AsyncValue trong Widget.
//
// Tuân thủ:
//   - mobile-flutter #2: Widget chỉ hiển thị — logic ở Controller
//   - mobile-flutter #4: xử lý 3 trạng thái data/loading/error
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'analysis_controller.dart';

class ColorAnalysisScreen extends ConsumerWidget {
  const ColorAnalysisScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final colorState = ref.watch(colorAnalysisProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Phân tích màu sắc')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickAndAnalyze(context, ref, ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Chụp ảnh'),
            ),
            const SizedBox(height: 12),
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

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sub-season: ${result.subSeason}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(result.explanation),
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
    );
  }
}
