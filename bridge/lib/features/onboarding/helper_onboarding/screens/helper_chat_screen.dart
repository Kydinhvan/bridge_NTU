import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/themes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../models/app_user.dart';
import '../../../../shared/services/ai_chat_service.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../../../shared/widgets/theme_chip.dart';

class HelperChatScreen extends ConsumerStatefulWidget {
  const HelperChatScreen({super.key});

  @override
  ConsumerState<HelperChatScreen> createState() => _HelperChatScreenState();
}

class _HelperChatScreenState extends ConsumerState<HelperChatScreen> {
  // Steps: 0=themes, 1=theme stories, 2=support style, 3=energy, 4=final
  int _step = 0;
  final Set<String> _selectedThemes = {};
  final Map<String, String> _themeNarratives = {}; // theme → text narrative
  int _currentThemeIdx = 0; // which theme story we're on
  String? _supportStyle;
  String? _energyLevel;
  bool _saving = false;

  static const _supportStyles = [
    {'icon': Icons.hearing_rounded, 'label': 'I mostly listen', 'value': 'listen'},
    {'icon': Icons.lightbulb_outline_rounded, 'label': 'I give advice', 'value': 'advice'},
    {'icon': Icons.handshake_rounded, 'label': 'I explore together', 'value': 'explore'},
    {'icon': Icons.forum_rounded, 'label': 'Mix of everything', 'value': 'mixed'},
  ];

  static const _energyLevels = [
    {'icon': Icons.bedtime_rounded, 'label': 'Low energy', 'value': 'low'},
    {'icon': Icons.eco_rounded, 'label': 'Moderate', 'value': 'moderate'},
    {'icon': Icons.wb_sunny_rounded, 'label': 'Good energy', 'value': 'high'},
    {'icon': Icons.bolt_rounded, 'label': 'Very energised', 'value': 'very_high'},
  ];

  List<String> get _themeList => _selectedThemes.toList();

  int get _totalSteps => 5; // themes, stories, support, energy, final

  Future<void> _finish() async {
    setState(() => _saving = true);

    // Send all narratives to backend for scoring
    try {
      await AiChatService.instance.extractHelperProfile(
        experienceNarrative: _themeNarratives.values.join('\n\n'),
        selectedThemes: _themeList,
        themeNarratives: _themeNarratives,
      );
    } catch (_) {
      // Fallback — profile still created with defaults
    }

    final uid = await FirebaseService.instance.signInAnonymously();
    await FirebaseService.instance.saveUser(AppUser(
      id: uid,
      role: UserRole.helper,
      ageDecade: '20s',
    ));
    if (!mounted) return;
    context.go('/helper/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.warmBrown),
                onPressed: () {
                  if (_step == 1 && _currentThemeIdx > 0) {
                    setState(() => _currentThemeIdx--);
                  } else {
                    setState(() {
                      _step--;
                      if (_step == 1) _currentThemeIdx = _themeList.length - 1;
                    });
                  }
                },
              )
            : null,
        title: Text('Become a helper', style: AppTypography.heading2Sans),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _progressValue(),
            backgroundColor: AppColors.warmBrown.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(AppColors.softSage),
          ),
        ),
      ),
      body: Responsive.centeredCard(
        context,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStep(),
        ),
      ),
    );
  }

  double _progressValue() {
    if (_step == 0) return 1 / _totalSteps;
    if (_step == 1) {
      final base = 1 / _totalSteps;
      final storyProgress = (_currentThemeIdx + 1) / _themeList.length;
      return base + storyProgress / _totalSteps;
    }
    return (_step + 1) / _totalSteps;
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _ThemeStep(
          key: const ValueKey(0),
          selectedThemes: _selectedThemes,
          onToggle: (t) => setState(() {
            if (_selectedThemes.contains(t)) {
              _selectedThemes.remove(t);
            } else {
              _selectedThemes.add(t);
            }
          }),
          onNext: _selectedThemes.isNotEmpty
              ? () => setState(() {
                    _currentThemeIdx = 0;
                    _step++;
                  })
              : null,
        );
      case 1:
        return _ThemeStoryStep(
          key: ValueKey('story_$_currentThemeIdx'),
          theme: _themeList[_currentThemeIdx],
          themeIndex: _currentThemeIdx,
          totalThemes: _themeList.length,
          initialText: _themeNarratives[_themeList[_currentThemeIdx]] ?? '',
          onNext: (text) {
            setState(() {
              _themeNarratives[_themeList[_currentThemeIdx]] = text;
              if (_currentThemeIdx < _themeList.length - 1) {
                _currentThemeIdx++;
              } else {
                _step++;
              }
            });
          },
          onSkip: () {
            setState(() {
              if (_currentThemeIdx < _themeList.length - 1) {
                _currentThemeIdx++;
              } else {
                _step++;
              }
            });
          },
        );
      case 2:
        return _PickStep(
          key: const ValueKey(2),
          title: 'How do you prefer to help?',
          options: _supportStyles,
          selected: _supportStyle,
          onSelect: (v) => setState(() {
            _supportStyle = v;
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _step++);
            });
          }),
        );
      case 3:
        return _PickStep(
          key: const ValueKey(3),
          title: "What's your usual energy level?",
          options: _energyLevels,
          selected: _energyLevel,
          onSelect: (v) => setState(() {
            _energyLevel = v;
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _step++);
            });
          }),
        );
      default:
        return _FinalStep(
          key: const ValueKey(4),
          saving: _saving,
          onFinish: _finish,
        );
    }
  }
}

// ── Step 0: Theme selection ──

class _ThemeStep extends StatelessWidget {
  final Set<String> selectedThemes;
  final void Function(String) onToggle;
  final VoidCallback? onNext;

  const _ThemeStep({
    super.key,
    required this.selectedThemes,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which of these have you personally navigated?',
            style: AppTypography.heading2Serif,
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that resonate. Your experience is your qualification.',
            style: AppTypography.bodySerif.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppThemes.all.map((theme) {
              return ThemeChip(
                theme: theme,
                selected: selectedThemes.contains(theme),
                interactive: true,
                onTap: () => onToggle(theme),
              );
            }).toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: onNext != null ? AppColors.softSage : AppColors.softSage.withValues(alpha: 0.4),
                foregroundColor: AppColors.cream,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: Text('Next', style: AppTypography.heading2Sans.copyWith(color: AppColors.cream)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Step 1: Per-theme story recording ──

class _ThemeStoryStep extends StatefulWidget {
  final String theme;
  final int themeIndex;
  final int totalThemes;
  final String initialText;
  final void Function(String text) onNext;
  final VoidCallback onSkip;

  const _ThemeStoryStep({
    super.key,
    required this.theme,
    required this.themeIndex,
    required this.totalThemes,
    required this.initialText,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<_ThemeStoryStep> createState() => _ThemeStoryStepState();
}

class _ThemeStoryStepState extends State<_ThemeStoryStep> {
  late TextEditingController _controller;

  static const _prompts = [
    'What was your experience with this? What happened?',
    'How did you cope or overcome it?',
    'What did you learn about yourself through this?',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconData = AppThemes.iconData[widget.theme] ?? Icons.chat_bubble_outline_rounded;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme badge + counter
          Row(
            children: [
              Icon(iconData, size: 28, color: AppColors.warmBrown),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.theme,
                  style: AppTypography.heading2Serif.copyWith(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softSage.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.themeIndex + 1} / ${widget.totalThemes}',
                  style: AppTypography.captionSans.copyWith(
                    color: AppColors.softSage,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Guided prompts
          Text(
            'Share your story',
            style: AppTypography.heading2Sans.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 10),
          ...List.generate(_prompts.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${i + 1}. ', style: AppTypography.bodySans.copyWith(
                  color: AppColors.amber, fontWeight: FontWeight.w700,
                )),
                Expanded(
                  child: Text(_prompts[i], style: AppTypography.bodySans.copyWith(
                    color: AppColors.warmBrown,
                  )),
                ),
              ],
            ),
          )),

          const SizedBox(height: 14),

          // Privacy disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.safeBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.safeBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.safeBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No one will read or listen to this. It is only used by our AI to better match you with someone you can truly help.',
                    style: AppTypography.captionSans.copyWith(
                      color: AppColors.safeBlue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Text input
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: AppTypography.bodySerif.copyWith(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Write about your experience here... (2–3 mins of thought)',
                hintStyle: AppTypography.bodySerif.copyWith(
                  color: AppColors.warmBrown.withValues(alpha: 0.35),
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.warmBrown.withValues(alpha: 0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.warmBrown.withValues(alpha: 0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.softSage, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: widget.onSkip,
                  child: Text('Skip this one',
                    style: AppTypography.bodySans.copyWith(color: AppColors.warmBrown),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => widget.onNext(_controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softSage,
                      foregroundColor: AppColors.cream,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.themeIndex < widget.totalThemes - 1 ? 'Next topic' : 'Continue',
                      style: AppTypography.heading2Sans.copyWith(color: AppColors.cream, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

// ── Step 2 & 3: Pick support style / energy ──

class _PickStep extends StatelessWidget {
  final String title;
  final List<Map<String, Object>> options;
  final String? selected;
  final void Function(String) onSelect;

  const _PickStep({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.heading2Serif),
          const SizedBox(height: 28),
          ...options.map((opt) {
            final isSelected = selected == opt['value'];
            return GestureDetector(
              onTap: () => onSelect(opt['value']! as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.softSage : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.softSage : AppColors.warmBrown.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(opt['icon']! as IconData,
                        size: 28,
                        color: isSelected ? AppColors.cream : AppColors.warmBrown),
                    const SizedBox(width: 16),
                    Text(opt['label']! as String, style: AppTypography.bodySans.copyWith(
                      color: isSelected ? AppColors.cream : AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    )),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Step 4: Final confirmation ──

class _FinalStep extends StatelessWidget {
  final bool saving;
  final VoidCallback onFinish;

  const _FinalStep({super.key, required this.saving, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco_rounded, size: 72, color: AppColors.softSage),
          const SizedBox(height: 24),
          Text(
            "You're all set.",
            style: AppTypography.heading1Serif,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Thank you for being willing to help. Your experience matters more than you know.",
            style: AppTypography.bodySerif.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: saving ? null : onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softSage,
                foregroundColor: AppColors.cream,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: saving
                  ? const CircularProgressIndicator(color: AppColors.cream)
                  : Text('Start helping', style: AppTypography.heading2Sans.copyWith(color: AppColors.cream)),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
    );
  }
}
