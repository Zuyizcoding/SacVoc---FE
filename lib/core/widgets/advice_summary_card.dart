import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_card.dart';

class AdviceSummaryCard extends StatelessWidget {
  final String title;
  final String advice;

  const AdviceSummaryCard({
    super.key,
    required this.title,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadii.r16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              advice,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
