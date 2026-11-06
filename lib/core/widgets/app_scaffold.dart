import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../theme/figma_palette.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scroll;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.child,
    this.padding = AppSpacing.pagePadding,
    this.scroll = false,
  });

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    final scaffold = Scaffold(
      appBar: appBar,
      backgroundColor: FigmaPalette.backgroundGradient == null
          ? AppColors.background
          : Colors.transparent,
      body: scroll ? SingleChildScrollView(child: body) : body,
    );

    final gradient = FigmaPalette.backgroundGradient;
    if (gradient == null) return scaffold;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: scaffold,
    );
  }
}
