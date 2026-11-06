import 'package:flutter/material.dart';

import '../theme/figma_palette.dart';

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  static const double _height = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDisabled = onPressed == null;

    final foreground = scheme.onPrimary;
    final decoration = BoxDecoration(
      gradient: isDisabled ? null : FigmaPalette.ctaGradient,
      color: isDisabled ? scheme.primary.withValues(alpha: 0.40) : null,
    );

    final content = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: Semantics(
        button: true,
        enabled: !isDisabled,
        child: Material(
          color: Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: decoration,
            child: InkWell(
              onTap: onPressed,
              child: Center(
                child: DefaultTextStyle(
                  style:
                      theme.textTheme.titleMedium!.copyWith(color: foreground),
                  child: IconTheme(
                    data: IconThemeData(color: foreground),
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
