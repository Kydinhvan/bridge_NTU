import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/role-selection');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo mark
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Icon(Icons.hub_rounded, size: 48, color: AppColors.cream),
              ),
            )
                .animate()
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            Text(
              'Bridge',
              style: AppTypography.heading1Serif.copyWith(fontSize: 48),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 10),

            Text(
              'Human-first support,\nright in your neighbourhood.',
              style: AppTypography.bodySerif.copyWith(
                color: AppColors.warmBrown.withValues(alpha: 0.7),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
