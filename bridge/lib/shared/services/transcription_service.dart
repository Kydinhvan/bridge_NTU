import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class TranscriptionService {
  static final TranscriptionService _instance = TranscriptionService._();
  TranscriptionService._();
  static TranscriptionService get instance => _instance;

  Future<String> transcribeAudio(String audioUrl) async {
    if (ApiConstants.useMock) return _mock();

    final res = await http.post(
      Uri.parse(ApiConstants.url(ApiConstants.transcribe)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'audio_url': audioUrl}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['transcript'] as String;
    }
    throw Exception('Transcription failed: ${res.statusCode}');
  }

  Future<String> _mock() async {
    await Future.delayed(const Duration(seconds: 2));
    return "I've been really struggling lately. My dad and I keep fighting about my career path. "
        "He wants me to be an engineer but I really want to do something creative. "
        "I feel like no one in my family understands me and it's been making me feel really alone.";
  }
}
