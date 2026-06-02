import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_buttons.dart';

class AppLoading extends StatefulWidget {
  final String? title;
  final List<String> messages;
  final IconData? icon;

  const AppLoading({
    super.key,
    this.title,
    this.messages = const [],
    this.icon,
  });

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading> {
  Timer? _timer;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.messages.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (!mounted) return;
        setState(() {
          _messageIndex = (_messageIndex + 1) % widget.messages.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMessage = widget.messages.isEmpty ? null : widget.messages[_messageIndex];
    if (widget.title == null && activeMessage == null && widget.icon == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSpacing.s16),
            ],
            const CircularProgressIndicator(),
            if (widget.title != null) ...[
              const SizedBox(height: AppSpacing.s16),
              Text(
                widget.title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
            if (activeMessage != null) ...[
              const SizedBox(height: AppSpacing.s8),
              Text(
                activeMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
            const SizedBox(height: AppSpacing.s16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.s24),
              AppSecondaryButton(label: 'Thử lại', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
