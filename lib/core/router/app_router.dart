import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/analysis/presentation/body_analysis_screen.dart';
import '../../features/analysis/presentation/color_analysis_screen.dart';
import '../../features/analysis/presentation/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/splash_screen.dart';
import '../../features/outfit/presentation/outfit_detail_screen.dart';
import '../../features/outfit/presentation/outfit_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/color',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const ColorAnalysisScreen(),
      ),
    ),
    GoRoute(
      path: '/body',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const BodyAnalysisScreen(),
      ),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const HistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/outfit',
      pageBuilder: (context, state) => _buildTransitionPage(
        state: state,
        child: const OutfitScreen(),
      ),
    ),
    GoRoute(
      path: '/outfit/:id',
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return _buildTransitionPage(
            state: state,
            child: const OutfitScreen(),
          );
        }
        return _buildTransitionPage(
          state: state,
          child: OutfitDetailScreen(outfitId: id),
        );
      },
    ),
  ],
);

CustomTransitionPage<void> _buildTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
  );
}
