import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/themes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';

class SeekerHomeScreen extends StatelessWidget {
  const SeekerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Responsive.centeredCard(
          context,
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(child: _VentCta()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Text(
                    'Browse by experience',
                    style: AppTypography.heading2Sans.copyWith(color: AppColors.warmBrown),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _ThemeLane(theme: AppThemes.all[i]),
                  childCount: AppThemes.all.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          const Icon(Icons.hub_rounded, size: 24, color: AppColors.amber),
          const SizedBox(width: 8),
          Text('Bridge', style: AppTypography.heading2Sans),
          const Spacer(),
          // Neighbourhood pulse
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.softSage.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: AppColors.softSage, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('12 nearby', style: AppTypography.captionSans.copyWith(
                  color: AppColors.softSage,
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _VentCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: GestureDetector(
        onTap: () => context.go('/seeker/vent'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.amber,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share what\'s on your mind',
                  style: AppTypography.heading2Serif.copyWith(color: AppColors.cream)),
              const SizedBox(height: 8),
              Text('We\'ll find someone who truly understands.',
                  style: AppTypography.bodySerif.copyWith(
                    color: AppColors.cream.withValues(alpha: 0.85),
                    fontSize: 17,
                  )),
              const SizedBox(height: 20),
              Row(
                children: [
                  _PillButton(icon: Icons.mic_rounded, label: 'Voice'),
                  const SizedBox(width: 10),
                  _PillButton(icon: Icons.edit_rounded, label: 'Text'),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PillButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.cream, size: 18),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.labelSans.copyWith(color: AppColors.cream)),
        ],
      ),
    );
  }
}

class _ThemeLane extends StatelessWidget {
  final String theme;
  const _ThemeLane({required this.theme});

  @override
  Widget build(BuildContext context) {
    final iconData = AppThemes.iconData[theme] ?? Icons.chat_bubble_outline_rounded;
    // Mock helper counts per theme
    const available = 3;
    const avgResponse = '~8 min';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.warmBrown.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(iconData, size: 28, color: AppColors.warmBrown),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(theme, style: AppTypography.labelSans.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmBrown,
                    )),
                    const SizedBox(height: 4),
                    Text('$available listening · responds $avgResponse',
                        style: AppTypography.captionSans),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.warmBrown.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
