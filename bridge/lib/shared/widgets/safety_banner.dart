import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Shown when safety classifier returns risk: high.
/// Warm, non-alarming — never blocks; always offers peer path too.
class SafetyBanner extends StatelessWidget {
  final VoidCallback? onContinueToPeerSupport;

  const SafetyBanner({super.key, this.onContinueToPeerSupport});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.safeBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.safeBlue.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: AppColors.safeBlue, size: 24),
              const SizedBox(width: 10),
              Text(
                'You\'re not alone',
                style: AppTypography.heading2Sans.copyWith(color: AppColors.safeBlue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'It sounds like you\'re carrying something really heavy right now. '
            'Trained counsellors are available to listen anytime.',
            style: AppTypography.bodySans.copyWith(color: AppColors.charcoal),
          ),
          const SizedBox(height: 20),
          _ResourceTile(
            icon: Icons.phone_rounded,
            label: 'SOS Helpline',
            detail: '1800-221-4444 (24/7)',
            color: AppColors.safeBlue,
          ),
          const SizedBox(height: 8),
          _ResourceTile(
            icon: Icons.chat_bubble_rounded,
            label: 'IMH Helpline',
            detail: '6389-2222',
            color: AppColors.safeBlue,
          ),
          const SizedBox(height: 20),
          if (onContinueToPeerSupport != null)
            TextButton(
              onPressed: onContinueToPeerSupport,
              child: Text(
                'Continue to peer support instead',
                style: AppTypography.labelSans.copyWith(
                  color: AppColors.charcoal.withValues(alpha: 0.6),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final Color color;

  const _ResourceTile({
    required this.icon,
    required this.label,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSans.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              )),
              Text(detail, style: AppTypography.captionSans.copyWith(
                color: AppColors.charcoal.withValues(alpha: 0.7),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
