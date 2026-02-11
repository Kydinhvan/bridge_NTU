import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/constants/conversation_modes.dart';

/// Generates in-chat AI whisper suggestions for Helpers.
/// These are never shown to the Seeker — only visible in the Helper's scaffold rail.
class ScaffoldService {
  static final ScaffoldService _instance = ScaffoldService._();
  ScaffoldService._();
  static ScaffoldService get instance => _instance;

  Future<String> getSuggestion({
    required ConversationMode mode,
    required List<Map<String, String>> recentMessages,
  }) async {
    if (ApiConstants.useMock) return _mockSuggestion(mode);

    final res = await http.post(
      Uri.parse(ApiConstants.url(ApiConstants.scaffold)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mode': mode.name,
        'system_prompt': mode.scaffoldPrompt,
        'messages': recentMessages,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['suggestion'] as String;
    }
    throw Exception('Scaffold failed: ${res.statusCode}');
  }

  Future<String> _mockSuggestion(ConversationMode mode) async {
    await Future.delayed(const Duration(milliseconds: 600));
    switch (mode) {
      case ConversationMode.vent:
        return 'Try: "I\'m here. Take all the time you need."';
      case ConversationMode.reflect:
        return 'Try: "It sounds like you\'re feeling really unseen. Is that right?"';
      case ConversationMode.clarity:
        return 'Try: "What feels most urgent to you right now — the situation, or how it makes you feel?"';
      case ConversationMode.growth:
        return 'Try: "What\'s one small thing that might make tomorrow feel slightly more okay?"';
    }
  }
}
