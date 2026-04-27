import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/analysis/presentation/body_analysis_screen.dart';
import '../../features/analysis/presentation/color_analysis_screen.dart';
import '../../features/outfit/presentation/outfit_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/color',
      builder: (context, state) => const ColorAnalysisScreen(),
    ),
    GoRoute(
      path: '/body',
      builder: (context, state) => const BodyAnalysisScreen(),
    ),
    GoRoute(
      path: '/outfit',
      builder: (context, state) => const OutfitScreen(),
    ),
  ],
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sắc Vóc')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/color'),
              child: const Text('Phân tích màu sắc'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/body'),
              child: const Text('Phân tích dáng người'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/outfit'),
              child: const Text('Gợi ý trang phục'),
            ),
          ],
        ),
      ),
    );
  }
}
