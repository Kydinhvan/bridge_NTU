import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../models/seeker_profile.dart';
import '../../models/helper_profile.dart';

/// Manages the GPT-4o onboarding chat and profile extraction.
class AiChatService {
  static final AiChatService _instance = AiChatService._();
  AiChatService._();
  static AiChatService get instance => _instance;

  /// Seeker onboarding — send accumulated conversation, get next AI message.
  Future<String> seekerChat(List<Map<String, String>> history) async {
    if (ApiConstants.useMock) return _mockSeekerChat(history);

    final res = await http.post(
      Uri.parse(ApiConstants.url(ApiConstants.extractProfile)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'messages': history, 'mode': 'seeker_chat'}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['reply'] as String;
    }
    throw Exception('Seeker chat failed: ${res.statusCode}');
  }

  /// Extract SeekerProfile from the full conversation transcript.
  Future<SeekerProfile> extractSeekerProfile(String ventText) async {
    if (ApiConstants.useMock) return _mockExtractSeeker();

    final res = await http.post(
      Uri.parse(ApiConstants.url(ApiConstants.extractProfile)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'transcript': ventText, 'mode': 'extract_seeker'}),
    );
    if (res.statusCode == 200) {
      return SeekerProfile.fromJson(jsonDecode(res.body));
    }
    throw Exception('Profile extraction failed: ${res.statusCode}');
  }

  /// Helper onboarding — extract HelperProfile from per-theme narratives.
  Future<HelperProfile> extractHelperProfile({
    required String experienceNarrative,
    required List<String> selectedThemes,
    Map<String, String>? themeNarratives,
  }) async {
    if (ApiConstants.useMock) return _mockExtractHelper();

    final res = await http.post(
      Uri.parse(ApiConstants.url(ApiConstants.extractProfile)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'narrative': experienceNarrative,
        'selected_themes': selectedThemes,
        if (themeNarratives != null && themeNarratives.isNotEmpty)
          'theme_narratives': themeNarratives,
        'mode': 'extract_helper',
      }),
    );
    if (res.statusCode == 200) {
      return HelperProfile.fromJson(jsonDecode(res.body));
    }
    throw Exception('Helper extraction failed: ${res.statusCode}');
  }

  // ── Mock implementations ──

  Future<String> _mockSeekerChat(List<Map<String, String>> history) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final count = history.where((m) => m['role'] == 'assistant').length;
    const responses = [
      "What's been on your mind lately? Take your time — there's no rush here.",
      "That sounds really heavy to carry. Can you tell me a bit more about what's been making it feel so overwhelming?",
      "I hear you. It takes courage to even say that out loud. How long has this been weighing on you?",
      "Thank you for sharing that with me. I'm going to find someone who truly understands what you're going through.",
    ];
    if (count < responses.length) return responses[count];
    return "Thank you for trusting me with this. Let me find someone who really gets it.";
  }

  Future<SeekerProfile> _mockExtractSeeker() async {
    await Future.delayed(const Duration(seconds: 1));
    return SeekerProfile.mock();
  }

  Future<HelperProfile> _mockExtractHelper() async {
    await Future.delayed(const Duration(seconds: 1));
    return HelperProfile.mock();
  }
}
