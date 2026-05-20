import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
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

  // NOTE: Backend chá»‰ filter giá»›i tÃ­nh khi request cÃ³ `gender=`.
  // Náº¿u app chÆ°a cÃ³ UI chá»n giá»›i tÃ­nh, báº¡n cÃ³ thá»ƒ Ä‘á»•i máº·c Ä‘á»‹nh á»Ÿ Ä‘Ã¢y.
  static const String _defaultGender = 'male';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(outfitControllerProvider.notifier)
          .loadRecommendations(gender: _defaultGender);
    });
  }

  Future<void> _showMissingAnalysisDialog() async {
    if (_isDialogShowing || !mounted) return;
    _isDialogShowing = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thiáº¿u dá»¯ liá»‡u phÃ¢n tÃ­ch'),
          content: const Text(
            'Báº¡n cáº§n phÃ¢n tÃ­ch mÃ u sáº¯c vÃ  dÃ¡ng ngÆ°á»i trÆ°á»›c',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/color');
              },
              child: const Text('PhÃ¢n tÃ­ch mÃ u sáº¯c'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/body');
              },
              child: const Text('PhÃ¢n tÃ­ch dÃ¡ng'),
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

    return AppScaffold(
      appBar: AppBar(title: const Text('Gá»£i Ã½ trang phá»¥c')),
      padding: EdgeInsets.zero,
      child: const OutfitGrid(),
    );
  }
}

