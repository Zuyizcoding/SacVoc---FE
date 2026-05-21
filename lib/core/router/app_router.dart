import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_scaffold.dart';
import '../../features/analysis/presentation/analysis_controller.dart';
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(analysisHistoryProvider);
    final history = historyState.asData?.value;
    final hasColor = history?.color != null;
    final hasBody = history?.body != null;
    final isOutfitReady = hasColor && hasBody;
    final nextLabel = !hasColor
        ? 'Bắt đầu bước 1'
        : !hasBody
            ? 'Tiếp tục bước 2'
            : 'Sang bước 3';
    final nextRoute = !hasColor
        ? '/color'
        : !hasBody
            ? '/body'
            : '/outfit';

    return AppScaffold(
      appBar: AppBar(title: const Text('Sắc Vóc')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo journey 3 bước',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Đi từ phân tích màu sắc và dáng người sang gợi ý outfit local có thể mua thật.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.s16),
                _DemoJourneyStepCard(
                  stepNumber: 1,
                  title: 'Màu sắc cá nhân',
                  subtitle: hasColor
                      ? 'Đã có kết quả màu sắc trong hồ sơ.'
                      : 'Chụp selfie rõ mặt để xác định mùa sắc.',
                  status: hasColor ? 'Hoàn tất' : 'Chưa làm',
                  isDone: hasColor,
                  onPressed: () => context.push('/color'),
                ),
                const SizedBox(height: 12),
                _DemoJourneyStepCard(
                  stepNumber: 2,
                  title: 'Dáng người',
                  subtitle: hasBody
                      ? 'Đã có kết quả dáng người trong hồ sơ.'
                      : 'Chụp ảnh toàn thân để hệ thống suy ra form phù hợp.',
                  status: hasBody ? 'Hoàn tất' : 'Chưa làm',
                  isDone: hasBody,
                  onPressed: () => context.push('/body'),
                ),
                const SizedBox(height: 12),
                _DemoJourneyStepCard(
                  stepNumber: 3,
                  title: 'Gợi ý outfit',
                  subtitle: isOutfitReady
                      ? 'Sẵn sàng tạo outfit cá nhân hóa cho phần demo.'
                      : 'Mở khóa sau khi hoàn thành cả F1 và F2.',
                  status: isOutfitReady ? 'Sẵn sàng' : 'Đang chờ dữ liệu',
                  isDone: isOutfitReady,
                  onPressed: () => context.push('/outfit'),
                ),
                const SizedBox(height: AppSpacing.s16),
                AppPrimaryButton(
                  label: nextLabel,
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => context.push(nextRoute),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
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
          if (historyState.isLoading) ...[
            const SizedBox(height: 12),
            Text(
              'Đang đồng bộ trạng thái hành trình demo...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _DemoJourneyStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final String status;
  final bool isDone;
  final VoidCallback onPressed;

  const _DemoJourneyStepCard({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isDone,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.r16),
        border: Border.all(
          color: isDone ? colorScheme.primary.withValues(alpha: 0.25) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isDone
                ? colorScheme.primary.withValues(alpha: 0.12)
                : Colors.grey.shade200,
            child: Text(
              '$stepNumber',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isDone ? colorScheme.primary : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.s4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  status,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isDone ? colorScheme.primary : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onPressed, child: const Text('Mở')),
        ],
      ),
    );
  }
}
