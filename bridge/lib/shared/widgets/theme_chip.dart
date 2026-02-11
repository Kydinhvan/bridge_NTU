import 'package:flutter/material.dart';
import '../../core/constants/themes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Colored chip representing one of the 7 fixed support themes.
class ThemeChip extends StatelessWidget {
  final String theme;
  final bool selected;
  final bool interactive;
  final VoidCallback? onTap;

  const ThemeChip({
    super.key,
    required this.theme,
    this.selected = false,
    this.interactive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = AppThemes.iconData[theme] ?? Icons.chat_bubble_outline_rounded;
    final bg = selected ? AppColors.amber : AppColors.amber.withValues(alpha: 0.12);
    final fg = selected ? AppColors.cream : AppColors.warmBrown;

    return GestureDetector(
      onTap: interactive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? AppColors.amber
                : AppColors.amber.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              theme,
              style: AppTypography.labelSans.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
