import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/services/audio_service.dart';
import '../../../shared/services/firebase_service.dart';
import '../../../shared/services/safety_service.dart';
import '../../../shared/services/transcription_service.dart';
import '../../../shared/widgets/waveform_widget.dart';

enum _VentMode { voice, text }

class VentScreen extends ConsumerStatefulWidget {
  const VentScreen({super.key});

  @override
  ConsumerState<VentScreen> createState() => _VentScreenState();
}

class _VentScreenState extends ConsumerState<VentScreen> {
  _VentMode _mode = _VentMode.voice;
  bool _isRecording = false;
  bool _hasRecording = false;
  String? _recordedPath;
  final _textController = TextEditingController();
  bool _submitting = false;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await AudioService.instance.stopRecording();
      setState(() {
        _isRecording = false;
        _hasRecording = path != null;
        _recordedPath = path;
      });
    } else {
      final ok = await AudioService.instance.hasPermission();
      if (!ok) return;
      await AudioService.instance.startRecording();
      setState(() {
        _isRecording = true;
        _hasRecording = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    String audioUrl = '';
    String transcript = '';

    if (_mode == _VentMode.voice && _recordedPath != null) {
      audioUrl = await AudioService.instance.uploadAudio(_recordedPath!);
      transcript = await TranscriptionService.instance.transcribeAudio(audioUrl);
    } else {
      transcript = _textController.text.trim();
      if (transcript.isEmpty) {
        setState(() => _submitting = false);
        return;
      }
    }

    final risk = await SafetyService.instance.assess(transcript);

    if (!mounted) return;
    if (SafetyService.instance.requiresIntervention(risk)) {
      context.go('/seeker/safety-check');
    } else {
      final uid = await FirebaseService.instance.getCurrentUserId() ?? '';
      await FirebaseService.instance.createVent(seekerId: uid, audioUrl: audioUrl);
      context.go('/seeker/processing', extra: transcript);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.warmBrown),
          onPressed: () => context.go('/seeker/home'),
        ),
        title: Text('Share', style: AppTypography.heading2Sans),
        actions: [
          // Toggle voice / text
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _ModeToggle(
                  icon: Icons.mic_rounded,
                  active: _mode == _VentMode.voice,
                  onTap: () => setState(() => _mode = _VentMode.voice),
                ),
                const SizedBox(width: 8),
                _ModeToggle(
                  icon: Icons.edit_rounded,
                  active: _mode == _VentMode.text,
                  onTap: () => setState(() => _mode = _VentMode.text),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Responsive.centeredCard(
        context,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _mode == _VentMode.voice ? _buildVoiceMode() : _buildTextMode(),
        ),
      ),
    );
  }

  Widget _buildVoiceMode() {
    return Column(
      children: [
        const Spacer(),
        Text(
          _isRecording
              ? 'Listening...'
              : _hasRecording
                  ? 'Recording saved'
                  : 'Hold to share',
          style: AppTypography.heading2Serif.copyWith(color: AppColors.warmBrown),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 32),

        WaveformWidget(
          isRecording: _isRecording,
          color: AppColors.terracotta,
          height: 72,
        ),

        const SizedBox(height: 40),

        // Record button
        GestureDetector(
          onTap: _toggleRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: _isRecording ? AppColors.terracotta : AppColors.amber,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? AppColors.terracotta : AppColors.amber)
                      .withValues(alpha: 0.4),
                  blurRadius: _isRecording ? 32 : 16,
                  spreadRadius: _isRecording ? 8 : 0,
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: AppColors.cream,
              size: 40,
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(end: _isRecording ? 1.05 : 1.0, duration: 600.ms),

        const SizedBox(height: 16),
        Text('Max 2 minutes', style: AppTypography.captionSans),

        const Spacer(),

        if (_hasRecording)
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: AppColors.cream)
                    : Text('Find my match',
                        style: AppTypography.heading2Sans.copyWith(color: AppColors.cream)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextMode() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Expanded(
          child: TextField(
            controller: _textController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: AppTypography.bodySerif.copyWith(fontSize: 20),
            decoration: InputDecoration(
              hintText: "It's okay to say anything here...",
              hintStyle: AppTypography.bodySerif.copyWith(
                color: AppColors.warmBrown.withValues(alpha: 0.35),
                fontSize: 20,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40, top: 16),
          child: SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: _submitting
                  ? const CircularProgressIndicator(color: AppColors.cream)
                  : Text('Find my match',
                      style: AppTypography.heading2Sans.copyWith(color: AppColors.cream)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ModeToggle({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? AppColors.amber : AppColors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: active ? AppColors.cream : AppColors.amber, size: 20),
      ),
    );
  }
}
