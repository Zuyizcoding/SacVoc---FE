import 'package:flutter/material.dart';

import '../../features/analysis/domain/color_result.dart';
import '../theme/app_tokens.dart';
import 'app_card.dart';

class MenswearGuidanceCard extends StatelessWidget {
  final MenswearGuide guidance;

  const MenswearGuidanceCard({
    super.key,
    required this.guidance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gợi ý cho trang phục nam',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s16),
          _GuidanceSection(
            title: 'Áo / layer',
            items: guidance.tops,
          ),
          const SizedBox(height: AppSpacing.s8),
          _GuidanceSection(
            title: 'Quần',
            items: guidance.bottoms,
          ),
          const SizedBox(height: AppSpacing.s8),
          _GuidanceSection(
            title: 'Phụ kiện',
            items: guidance.accessories,
          ),
        ],
      ),
    );
  }
}

class _GuidanceSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _GuidanceSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $item',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
