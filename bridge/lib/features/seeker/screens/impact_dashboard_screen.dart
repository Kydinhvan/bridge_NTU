import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';

class ImpactDashboardScreen extends StatelessWidget {
  const ImpactDashboardScreen({super.key});

  // Mock data — delta from baseline to latest
  static const _lonelinessData = [7.0, 7.0, 6.0, 5.0, 4.0];
  static const _belongingData = [2.0, 2.0, 3.0, 3.0, 4.0];
  static const _moodData = [2.0, 2.0, 3.0, 3.0, 4.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.warmBrown),
          onPressed: () => context.go('/seeker/chat'),
        ),
        title: Text('Your impact', style: AppTypography.heading2Sans),
      ),
      body: Responsive.centeredCard(
        context,
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatRow(
                label: 'Sessions completed',
                value: '2',
                icon: Icons.spa_rounded,
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 8),

              _StatRow(
                label: 'Total connecting time',
                value: '38 min',
                icon: Icons.timer_outlined,
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              Text('Loneliness over time',
                  style: AppTypography.heading2Sans.copyWith(color: AppColors.warmBrown)),
              Text('Lower is better · UCLA scale 1–9',
                  style: AppTypography.captionSans),
              const SizedBox(height: 16),
              _LineChart(
                data: _lonelinessData,
                color: AppColors.terracotta,
                inverted: true,
              ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 32),

              Text('Sense of belonging',
                  style: AppTypography.heading2Sans.copyWith(color: AppColors.warmBrown)),
              Text('Higher is better · scale 1–5',
                  style: AppTypography.captionSans),
              const SizedBox(height: 16),
              _LineChart(
                data: _belongingData,
                color: AppColors.softSage,
                inverted: false,
              ).animate(delay: 300.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 32),

              Text('Mood trend',
                  style: AppTypography.heading2Sans.copyWith(color: AppColors.warmBrown)),
              Text('Higher is better · scale 1–5',
                  style: AppTypography.captionSans),
              const SizedBox(height: 16),
              _LineChart(
                data: _moodData,
                color: AppColors.amber,
                inverted: false,
              ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.softSage.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.softSage.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.eco_rounded, size: 32, color: AppColors.softSage),
                    const SizedBox(height: 8),
                    Text(
                      'You\'ve completed 2 sessions.\nYou\'re not alone.',
                      style: AppTypography.heading2Serif.copyWith(
                        color: AppColors.warmBrown,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warmBrown.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: AppColors.amber),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppTypography.bodySans)),
          Text(value, style: AppTypography.heading2Sans.copyWith(color: AppColors.amber)),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final bool inverted;
  const _LineChart({required this.data, required this.color, required this.inverted});

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final labels = ['Start', '', 'Wk 1', '', 'Wk 2'];
                  final i = v.round();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Text(labels[i], style: AppTypography.captionSans);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
