import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

enum RiskLevel { low, medium, high }

class SafetyService {
  static final SafetyService _instance = SafetyService._();
  SafetyService._();
  static SafetyService get instance => _instance;

  Future<RiskLevel> assess(String transcript) async {
    if (ApiConstants.useMock) return _mock();

    final res = await http.post(
      Uri.parse(ApiConstants.url(ApiConstants.safetyCheck)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'transcript': transcript}),
    );
    if (res.statusCode == 200) {
      final level = jsonDecode(res.body)['risk_level'] as String;
      return RiskLevel.values.firstWhere((e) => e.name == level);
    }
    throw Exception('Safety check failed: ${res.statusCode}');
  }

  /// Returns true if the session should be paused for safety resources.
  bool requiresIntervention(RiskLevel level) => level == RiskLevel.high;

  Future<RiskLevel> _mock() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return RiskLevel.low;
  }
}
