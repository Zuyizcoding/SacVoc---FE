import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/outfit_repository.dart';
import '../domain/outfit_result.dart';
import 'outfit_controller.dart';
import 'widgets/outfit_grid.dart';

class OutfitScreen extends ConsumerStatefulWidget {
  const OutfitScreen({super.key});

  @override
  ConsumerState<OutfitScreen> createState() => _OutfitScreenState();
}

class _OutfitScreenState extends ConsumerState<OutfitScreen> {
  bool _isDialogShowing = false;
  bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(outfitControllerProvider.notifier).loadRecommendations();
    });
  }

  Future<void> _showMissingAnalysisDialog() async {
    if (_isDialogShowing || !mounted) return;
    _isDialogShowing = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thiếu dữ liệu phân tích'),
          content: const Text(
            'Bạn cần phân tích màu sắc và dáng người trước',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/color');
              },
              child: const Text('Phân tích màu sắc'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/body');
              },
              child: const Text('Phân tích dáng'),
            ),
          ],
        );
      },
    );

    _isDialogShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<OutfitResult?>>(outfitControllerProvider, (_, next) {
      final error = next.error;
      if (error is MissingAnalysisException) {
        _showMissingAnalysisDialog();
      }

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
      appBar: AppBar(title: const Text('Gợi ý trang phục')),
      body: const OutfitGrid(),
    );
  }
}
