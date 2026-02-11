class SeekerProfile {
  final String userId;
  final List<Map<String, dynamic>> themes;
  final Map<String, double> copingStylePreference;
  final Map<String, double> conversationPreference;
  final String energyLevel;
  final String distressLevel;
  final double urgency;
  final String? ventText;

  SeekerProfile({
    required this.userId,
    required this.themes,
    required this.copingStylePreference,
    required this.conversationPreference,
    required this.energyLevel,
    required this.distressLevel,
    required this.urgency,
    this.ventText,
  });

  static SeekerProfile mock() => SeekerProfile(
    userId: 'mock_seeker',
    themes: [{'name': 'Family Problems', 'intensity': 0.9}],
    copingStylePreference: {
      'problem_focused': 0.3, 'emotion_focused': 0.8,
      'social_support': 0.9, 'avoidant': 0.1, 'meaning_making': 0.4,
    },
    conversationPreference: {
      'direct_advice': 0.3, 'reflective_listening': 0.9,
      'collaborative_problem_solving': 0.5, 'validation_focused': 0.8,
    },
    energyLevel: 'depleted',
    distressLevel: 'High',
    urgency: 0.85,
    ventText: 'I keep fighting with my dad about my career path.',
  );

  factory SeekerProfile.fromJson(Map<String, dynamic> json) => SeekerProfile(
    userId: json['user_id'] as String? ?? '',
    themes: (json['themes'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [],
    copingStylePreference: Map<String, double>.from(
        (json['coping_style_preference'] as Map?) ?? {}),
    conversationPreference: Map<String, double>.from(
        (json['conversation_preference'] as Map?) ?? {}),
    energyLevel: json['energy_level'] as String? ?? 'moderate',
    distressLevel: json['distress_level'] as String? ?? 'Medium',
    urgency: (json['urgency'] as num?)?.toDouble() ?? 0.5,
    ventText: json['vent_text'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'role': 'seeker',
    'themes': themes,
    'coping_style_preference': copingStylePreference,
    'conversation_preference': conversationPreference,
    'energy_level': energyLevel,
    'distress_level': distressLevel,
    'urgency': urgency,
    if (ventText != null) 'vent_text': ventText,
  };
}
