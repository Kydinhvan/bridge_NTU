import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/wellbeing_snapshot.dart';
import '../../../shared/services/firebase_service.dart';
import '../../../shared/widgets/wellbeing_slider.dart';

class WellbeingBaselineScreen extends ConsumerStatefulWidget {
  final String role; // 'seeker' | 'helper'

  const WellbeingBaselineScreen({super.key, required this.role});

  @override
  ConsumerState<WellbeingBaselineScreen> createState() => _WellbeingBaselineScreenState();
}

class _WellbeingBaselineScreenState extends ConsumerState<WellbeingBaselineScreen> {
  double _loneliness = 5;
  double _mood = 3;
  double _belonging = 3;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final uid = await FirebaseService.instance.signInAnonymously();
    final snap = WellbeingSnapshot(
      id: const Uuid().v4(),
      userId: uid,
      lonelinessScore: _loneliness.round(),
      moodScore: _mood.round(),
      belongingScore: _belonging.round(),
      sessionNumber: 0,
      createdAt: DateTime.now(),
    );
    await FirebaseService.instance.saveWellbeingSnapshot(uid, snap);

    if (!mounted) return;
    if (widget.role == 'seeker') {
      context.go('/onboarding/seeker-chat');
    } else {
      context.go('/onboarding/helper-chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Responsive.centeredCard(
          context,
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before we begin...',
                  style: AppTypography.heading1Serif,
                ),
                const SizedBox(height: 8),
                Text(
                  'A few quick check-ins. These help us measure how you feel over time.',
                  style: AppTypography.bodySerif.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 40),

                WellbeingSlider(
                  label: 'How lonely do you feel right now?',
                  leftLabel: 'Not at all',
                  rightLabel: 'Very lonely',
                  value: _loneliness,
                  min: 1,
                  max: 9,
                  divisions: 8,
                  onChanged: (v) => setState(() => _loneliness = v),
                  activeColor: AppColors.terracotta,
                ),

                const SizedBox(height: 36),

                WellbeingSlider(
                  label: "How's your mood today?",
                  leftLabel: '😔',
                  rightLabel: '😊',
                  value: _mood,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (v) => setState(() => _mood = v),
                  activeColor: AppColors.amber,
                ),

                const SizedBox(height: 36),

                WellbeingSlider(
                  label: 'How connected do you feel to those around you?',
                  leftLabel: 'Disconnected',
                  rightLabel: 'Very connected',
                  value: _belonging,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (v) => setState(() => _belonging = v),
                  activeColor: AppColors.softSage,
                ),

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: AppColors.cream,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const CircularProgressIndicator(color: AppColors.cream)
                        : Text('Continue', style: AppTypography.heading2Sans.copyWith(
                            color: AppColors.cream,
                          )),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Your responses are private and never shared.',
                  style: AppTypography.captionSans.copyWith(
                    color: AppColors.warmBrown.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
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
