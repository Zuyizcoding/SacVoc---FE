import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';

class AnalysisSourceBanner extends StatelessWidget {
  final String message;
  const AnalysisSourceBanner({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.wifi_tethering_error_rounded,
              color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
