import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/theme_chip.dart';

class HelperHomeScreen extends StatelessWidget {
  const HelperHomeScreen({super.key});

  // Mock pending requests
  static final _requests = [
    {
      'theme': 'Family Problems',
      'distress': 'High',
      'waiting': '3 min ago',
      'snippet': 'Having a hard time at home lately...',
    },
    {
      'theme': 'Loneliness / Isolation',
      'distress': 'Medium',
      'waiting': '12 min ago',
      'snippet': 'Feeling really disconnected from everyone.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Responsive.centeredCard(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    const Icon(Icons.eco_rounded, size: 28, color: AppColors.softSage),
                    const SizedBox(width: 10),
                    Text('Helper hub', style: AppTypography.heading2Sans),
                    const Spacer(),
                    // Private reputation badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.softSage.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.softSage),
                          const SizedBox(width: 4),
                          Text('4.8', style: AppTypography.captionSans.copyWith(
                            color: AppColors.softSage,
                            fontWeight: FontWeight.w700,
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Text(
                  '${_requests.length} people waiting for someone like you',
                  style: AppTypography.bodySerif.copyWith(
                    color: AppColors.warmBrown,
                    fontSize: 18,
                  ),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _requests.length,
                  itemBuilder: (context, i) {
                    return _RequestCard(
                      request: _requests[i],
                      onAccept: () => context.go('/helper/request'),
                    ).animate(delay: Duration(milliseconds: 150 + i * 100))
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                ),
              ),

              // Private reputation section
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softSage.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.softSage.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your private stats', style: AppTypography.labelSans.copyWith(
                      color: AppColors.warmBrown,
                      fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 12),
                    _ReputationRow('Warmth', 0.95),
                    _ReputationRow('Consistency', 0.88),
                    _ReputationRow('Safety score', 0.92),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, String> request;
  final VoidCallback onAccept;
  const _RequestCard({required this.request, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final isHighDistress = request['distress'] == 'High';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighDistress
              ? AppColors.terracotta.withValues(alpha: 0.3)
              : AppColors.warmBrown.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmBrown.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ThemeChip(theme: request['theme']!),
              const Spacer(),
              if (isHighDistress)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Needs support now',
                      style: AppTypography.captionSans.copyWith(color: AppColors.terracotta)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${request['snippet']!}"',
            style: AppTypography.bodySerif.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(request['waiting']!,
                  style: AppTypography.captionSans.copyWith(
                    color: AppColors.warmBrown.withValues(alpha: 0.5),
                  )),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text('Not now',
                    style: AppTypography.labelSans.copyWith(
                      color: AppColors.warmBrown.withValues(alpha: 0.4),
                    )),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softSage,
                    foregroundColor: AppColors.cream,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text('Accept', style: AppTypography.labelSans.copyWith(
                    color: AppColors.cream,
                    fontWeight: FontWeight.w700,
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReputationRow extends StatelessWidget {
  final String label;
  final double value;
  const _ReputationRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTypography.captionSans.copyWith(
              color: AppColors.charcoal,
            )),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.softSage.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.softSage),
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(value * 100).round()}%',
              style: AppTypography.captionSans.copyWith(
                color: AppColors.softSage,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
