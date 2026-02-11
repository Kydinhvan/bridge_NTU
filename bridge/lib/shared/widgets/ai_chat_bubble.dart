import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum BubbleRole { ai, user }

/// Chat bubble used in the onboarding AI conversation screens.
class AiChatBubble extends StatelessWidget {
  final String text;
  final BubbleRole role;
  final bool animate;

  const AiChatBubble({
    super.key,
    required this.text,
    required this.role,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final isAi = role == BubbleRole.ai;
    final bgColor = isAi ? AppColors.warmBrown : AppColors.amber;
    final textColor = AppColors.cream;
    final alignment = isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final borderRadius = isAi
        ? const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    final bubble = Column(
      crossAxisAlignment: alignment,
      children: [
        if (isAi) ...[
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.warmBrown.withValues(alpha: 0.15),
                child: const Icon(Icons.hub_rounded, size: 14, color: AppColors.warmBrown),
              ),
              const SizedBox(width: 8),
              Text('Bridge', style: AppTypography.captionSans.copyWith(
                color: AppColors.warmBrown,
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: AppTypography.bodySerif.copyWith(
              color: textColor,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );

    if (!animate) return bubble;
    return bubble
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.15, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
