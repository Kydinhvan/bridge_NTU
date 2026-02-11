import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/safety_banner.dart';

class SafetyCheckScreen extends StatelessWidget {
  const SafetyCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Responsive.centeredCard(
          context,
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'It sounds like you\'re carrying something heavy right now.',
                    style: AppTypography.heading2Serif.copyWith(
                      color: AppColors.warmBrown,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Trained counsellors are here for you — no waiting, no judgment.',
                    style: AppTypography.bodySerif.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                SafetyBanner(
                  onContinueToPeerSupport: () => context.go('/seeker/processing'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
