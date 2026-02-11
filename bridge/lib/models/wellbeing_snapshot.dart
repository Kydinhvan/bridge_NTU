import 'dart:convert';

class WellbeingSnapshot {
  final String id;
  final String userId;
  final int lonelinessScore;
  final int moodScore;
  final int belongingScore;
  final int sessionNumber;
  final DateTime createdAt;

  WellbeingSnapshot({
    required this.id,
    required this.userId,
    required this.lonelinessScore,
    required this.moodScore,
    required this.belongingScore,
    required this.sessionNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'loneliness_score': lonelinessScore,
    'mood_score': moodScore,
    'belonging_score': belongingScore,
    'session_number': sessionNumber,
    'created_at': createdAt.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory WellbeingSnapshot.fromJson(Map<String, dynamic> json) => WellbeingSnapshot(
    id: json['id'] ?? '',
    userId: json['user_id'] ?? '',
    lonelinessScore: json['loneliness_score'] ?? 5,
    moodScore: json['mood_score'] ?? 3,
    belongingScore: json['belonging_score'] ?? 3,
    sessionNumber: json['session_number'] ?? 0,
    createdAt: DateTime.parse(json['created_at']),
  );

  static WellbeingSnapshot fromJsonString(String s) =>
      WellbeingSnapshot.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
