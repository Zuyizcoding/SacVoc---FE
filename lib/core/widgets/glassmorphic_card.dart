// GlassmorphicCard — Container với hiệu ứng kính mờ.
//
//
// Sử dụng:
//   GlassmorphicCard(
//     child: Text('Nội dung bên trong'),
//   )
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsets? padding;
  final double borderRadius;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.15,
    this.padding,
    this.borderRadius = AppTheme.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppTheme.cardShadow, // Bóng đổ mềm
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacing24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
