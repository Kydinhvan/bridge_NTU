import 'helper_profile.dart';

class ScoreBreakdown {
  final double emotionalSimilarity;
  final double experienceOverlap;
  final double copingStyleMatch;
  final double availabilityOverlap;
  final double reliabilityScore;
  final double conversationBonus;
  final double energyBonus;

  ScoreBreakdown({
    required this.emotionalSimilarity,
    required this.experienceOverlap,
    required this.copingStyleMatch,
    required this.availabilityOverlap,
    required this.reliabilityScore,
    required this.conversationBonus,
    required this.energyBonus,
  });

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) =>
      ScoreBreakdown(
        emotionalSimilarity:
            (json['emotional_similarity'] as num?)?.toDouble() ?? 0,
        experienceOverlap:
            (json['experience_overlap'] as num?)?.toDouble() ?? 0,
        copingStyleMatch:
            (json['coping_style_match'] as num?)?.toDouble() ?? 0,
        availabilityOverlap:
            (json['availability_overlap'] as num?)?.toDouble() ?? 0,
        reliabilityScore:
            (json['reliability_score'] as num?)?.toDouble() ?? 0,
        conversationBonus:
            (json['conversation_bonus'] as num?)?.toDouble() ?? 0,
        energyBonus: (json['energy_bonus'] as num?)?.toDouble() ?? 0,
      );

  static ScoreBreakdown mock() => ScoreBreakdown(
    emotionalSimilarity: 0.87,
    experienceOverlap: 0.80,
    copingStyleMatch: 0.75,
    availabilityOverlap: 0.60,
    reliabilityScore: 0.92,
    conversationBonus: 0.08,
    energyBonus: 0.05,
  );
}

class MatchResult {
  final String matchId;
  final String helperId;
  final double score;
  final ScoreBreakdown breakdown;
  final String explanation;
  final HelperProfile helper;
  final String topTheme;

  MatchResult({
    required this.matchId,
    required this.helperId,
    required this.score,
    required this.breakdown,
    required this.explanation,
    required this.helper,
    required this.topTheme,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) => MatchResult(
    matchId: json['match_id'] as String? ?? '',
    helperId: json['helper_id'] as String? ?? '',
    score: (json['score'] as num?)?.toDouble() ?? 0,
    breakdown: ScoreBreakdown.fromJson(
        (json['breakdown'] as Map<String, dynamic>?) ?? {}),
    explanation: json['explanation'] as String? ?? '',
    helper: HelperProfile.fromJson(
        (json['helper'] as Map<String, dynamic>?) ?? {}),
    topTheme: json['top_theme'] as String? ?? '',
  );

  static MatchResult mock() => MatchResult(
    matchId: 'match_001',
    helperId: 'mock_helper',
    score: 0.82,
    breakdown: ScoreBreakdown.mock(),
    explanation: 'Matched because both have navigated family expectations and career crossroads. Your need for reflective listening aligns with their natural support style.',
    helper: HelperProfile.mock(),
    topTheme: 'Family Problems',
  );
}
