import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_tokens.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_scaffold.dart';
import '../../features/analysis/presentation/body_analysis_screen.dart';
import '../../features/analysis/presentation/color_analysis_screen.dart';
import '../../features/analysis/presentation/history_screen.dart';
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: const Text(
                'Sắc Vóc',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Sắc Vóc')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPrimaryButton(
            label: 'Phân tích màu sắc',
            onPressed: () => context.push('/color'),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppPrimaryButton(
            label: 'Phân tích dáng người',
            onPressed: () => context.push('/body'),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppPrimaryButton(
            label: 'Gợi ý trang phục',
            onPressed: () => context.push('/outfit'),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppSecondaryButton(
            label: 'Xem lại kết quả',
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
    );
  }
}
