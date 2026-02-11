class HelperProfile {
  final String userId;
  final String displayName;
  final String ageDecade;
  final Map<String, double> themesExperience;
  final Map<String, double> copingStyleExpertise;
  final Map<String, double> conversationStyle;
  final String energyLevel;
  final double reliabilityScore;
  final double responseRate;
  final double completionRate;
  final String? experienceNarrative;

  HelperProfile({
    required this.userId,
    required this.displayName,
    required this.ageDecade,
    required this.themesExperience,
    required this.copingStyleExpertise,
    required this.conversationStyle,
    required this.energyLevel,
    required this.reliabilityScore,
    required this.responseRate,
    required this.completionRate,
    this.experienceNarrative,
  });

  static HelperProfile mock() => HelperProfile(
    userId: 'mock_helper',
    displayName: 'Uncle Ravi',
    ageDecade: '60s',
    themesExperience: {
      'Family Problems': 0.9,
      'Life Direction / Purpose': 0.85,
      'Burnout / Emotional Exhaustion': 0.5,
    },
    copingStyleExpertise: {
      'emotion_focused': 0.9, 'social_support': 0.8,
      'meaning_making': 0.7, 'problem_focused': 0.6, 'avoidant': 0.2,
    },
    conversationStyle: {
      'reflective_listening': 0.95, 'validation_focused': 0.9,
      'collaborative_problem_solving': 0.6, 'direct_advice': 0.3,
    },
    energyLevel: 'moderate',
    reliabilityScore: 0.92,
    responseRate: 0.95,
    completionRate: 0.88,
    experienceNarrative: 'I struggled with family expectations and career choices in my 30s.',
  );

  factory HelperProfile.fromJson(Map<String, dynamic> json) => HelperProfile(
    userId: json['user_id'] as String? ?? '',
    displayName: json['display_name'] as String? ?? 'Anonymous Helper',
    ageDecade: json['age_decade'] as String? ?? '30s',
    themesExperience: Map<String, double>.from(
        (json['themes_experience'] as Map?) ?? {}),
    copingStyleExpertise: Map<String, double>.from(
        (json['coping_style_expertise'] as Map?) ?? {}),
    conversationStyle: Map<String, double>.from(
        (json['conversation_style'] as Map?) ?? {}),
    energyLevel: json['energy_level'] as String? ?? 'moderate',
    reliabilityScore: (json['reliability_score'] as num?)?.toDouble() ?? 0.8,
    responseRate: (json['response_rate'] as num?)?.toDouble() ?? 0.8,
    completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.8,
    experienceNarrative: json['experience_narrative'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'role': 'helper',
    'themes_experience': themesExperience,
    'coping_style_expertise': copingStyleExpertise,
    'conversation_style': conversationStyle,
    'energy_level': energyLevel,
    'reliability_score': reliabilityScore,
    'response_rate': responseRate,
    'completion_rate': completionRate,
    if (experienceNarrative != null) 'experience_narrative': experienceNarrative,
  };
}
