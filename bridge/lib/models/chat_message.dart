import 'dart:convert';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final String mode;
  final bool isAiScaffold;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.mode,
    required this.isAiScaffold,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'text': text,
    'mode': mode,
    'is_ai_scaffold': isAiScaffold,
    'created_at': createdAt.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] ?? '',
    senderId: json['sender_id'] ?? '',
    text: json['text'] ?? '',
    mode: json['mode'] ?? 'vent',
    isAiScaffold: json['is_ai_scaffold'] ?? false,
    createdAt: DateTime.parse(json['created_at']),
  );

  static ChatMessage fromJsonString(String s) =>
      ChatMessage.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
