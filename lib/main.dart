import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(child: SacVocApp()),
  );
}

class SacVocApp extends StatelessWidget {
  const SacVocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sắc Vóc',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('Sắc Vóc — Phase 1 OK ✓')),
      ),
    );
  }
}
