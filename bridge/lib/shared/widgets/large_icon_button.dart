import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Min 72×72px touch target — WCAG + elderly standard.
class LargeIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? iconColor;
  final VoidCallback onTap;
  final double size;

  const LargeIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.iconColor,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: iconColor ?? AppColors.cream),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.labelSans.copyWith(
                color: iconColor ?? AppColors.cream,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
