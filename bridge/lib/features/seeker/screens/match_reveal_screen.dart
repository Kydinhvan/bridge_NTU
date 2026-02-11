import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/match_result.dart';
import '../../../shared/widgets/theme_chip.dart';

class MatchRevealScreen extends StatefulWidget {
  final MatchResult? match;
  const MatchRevealScreen({super.key, this.match});

  @override
  State<MatchRevealScreen> createState() => _MatchRevealScreenState();
}

class _MatchRevealScreenState extends State<MatchRevealScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _mergeController;
  bool _showCard = false;

  late MatchResult _match;

  @override
  void initState() {
    super.initState();
    _match = widget.match ?? MatchResult.mock();
    _mergeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _mergeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _showCard = true);
    });
  }

  @override
  void dispose() {
    _mergeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepPlum,
      body: SafeArea(
        child: Responsive.centeredCard(
          context,
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                _MergeAnimation(controller: _mergeController),
                const SizedBox(height: 32),

                Text(
                  'Someone has walked\nthis path too',
                  style: AppTypography.heading1Serif.copyWith(color: AppColors.cream),
                  textAlign: TextAlign.center,
                ).animate(delay: 600.ms).fadeIn(duration: 600.ms),

                const SizedBox(height: 40),

                if (_showCard)
                  _MatchCard(match: _match)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.15, end: 0),

                const SizedBox(height: 32),

                if (_showCard)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () => context.go('/seeker/chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber,
                          foregroundColor: AppColors.cream,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: Text('Start the conversation',
                            style: AppTypography.heading2Sans
                                .copyWith(color: AppColors.cream)),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MergeAnimation extends StatelessWidget {
  final AnimationController controller;
  const _MergeAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final offset = (1 - controller.value) * 40;
        return SizedBox(
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(-offset, 0),
                child: _Circle(color: AppColors.amber.withValues(alpha: 0.7)),
              ),
              Transform.translate(
                offset: Offset(offset, 0),
                child: _Circle(color: AppColors.softSage.withValues(alpha: 0.7)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Circle extends StatelessWidget {
  final Color color;
  const _Circle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchResult match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final bd = match.breakdown;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Helper silhouette
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.softSage.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Icon(Icons.person_rounded, size: 28, color: AppColors.softSage)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your helper', style: AppTypography.captionSans.copyWith(
                      color: AppColors.cream.withValues(alpha: 0.6),
                    )),
                    Text('40s · Your neighbourhood',
                        style: AppTypography.labelSans.copyWith(color: AppColors.cream)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.softSage.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(match.score * 100).round()}% match',
                    style: AppTypography.labelSans.copyWith(color: AppColors.softSage),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            ThemeChip(theme: match.topTheme),

            const SizedBox(height: 20),
            Text(match.explanation,
                style: AppTypography.bodySerif.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.85),
                  fontSize: 17,
                )),

            const SizedBox(height: 20),
            Text('Why this match', style: AppTypography.labelSans.copyWith(
              color: AppColors.cream.withValues(alpha: 0.5),
            )),
            const SizedBox(height: 10),
            _ScoreRow('Emotional resonance', bd.emotionalSimilarity),
            _ScoreRow('Shared experience', bd.experienceOverlap),
            _ScoreRow('Support style fit', bd.copingStyleMatch),
            _ScoreRow('Reliability', bd.reliabilityScore),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double value;
  const _ScoreRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTypography.captionSans.copyWith(
              color: AppColors.cream.withValues(alpha: 0.65),
            )),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(AppColors.amber.withValues(alpha: 0.8)),
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
