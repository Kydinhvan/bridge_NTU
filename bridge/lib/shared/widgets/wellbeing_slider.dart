import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Warm custom slider for mood/loneliness/belonging scores.
class WellbeingSlider extends StatelessWidget {
  final String label;
  final String leftLabel;
  final String rightLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final Color? activeColor;

  const WellbeingSlider({
    super.key,
    required this.label,
    required this.leftLabel,
    required this.rightLabel,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 9,
    this.divisions = 8,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.amber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySans.copyWith(
          color: AppColors.warmBrown,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        )),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(leftLabel, style: AppTypography.captionSans.copyWith(
                color: AppColors.charcoal.withValues(alpha: 0.6),
              )),
              Text(
                value.round().toString(),
                style: AppTypography.heading2Sans.copyWith(color: color),
              ),
              Text(rightLabel, style: AppTypography.captionSans.copyWith(
                color: AppColors.charcoal.withValues(alpha: 0.6),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
