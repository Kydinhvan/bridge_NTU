import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

/// Animated waveform — pulses during recording, static bars during playback.
class WaveformWidget extends StatefulWidget {
  final bool isRecording;
  final bool isPlaying;
  final Color? color;
  final int barCount;
  final double height;

  const WaveformWidget({
    super.key,
    this.isRecording = false,
    this.isPlaying = false,
    this.color,
    this.barCount = 24,
    this.height = 56,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();
  late List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(widget.barCount, (_) => 0.2 + _random.nextDouble() * 0.8);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() {
        if (widget.isRecording) {
          setState(() {
            _barHeights = List.generate(
              widget.barCount,
              (_) => 0.15 + _random.nextDouble() * 0.85,
            );
          });
        }
      });

    if (widget.isRecording) _controller.repeat();
  }

  @override
  void didUpdateWidget(WaveformWidget old) {
    super.didUpdateWidget(old);
    if (widget.isRecording && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRecording && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.terracotta;
    final active = widget.isRecording || widget.isPlaying;

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(widget.barCount, (i) {
          final h = active ? _barHeights[i] : 0.3;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 3,
            height: widget.height * h,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: active ? color : color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    ).animate(target: active ? 1 : 0).scaleY(begin: 0.6, end: 1.0);
  }
}
