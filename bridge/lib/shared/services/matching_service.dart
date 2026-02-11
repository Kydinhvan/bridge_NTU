import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../models/seeker_profile.dart';
import '../../models/match_result.dart';

class MatchingService {
  static final MatchingService _instance = MatchingService._();
  MatchingService._();
  static MatchingService get instance => _instance;

  Future<MatchResult> findMatch(
    SeekerProfile seeker,
    List<String>? helperIds,
  ) async {
    if (ApiConstants.useMock) return _mockMatch();

    final body = <String, dynamic>{
      'seeker_profile': seeker.toJson(),
    };
    if (helperIds != null && helperIds.isNotEmpty) {
      body['helper_ids'] = helperIds;
    }

    final res = await http.post(
      Uri.parse(ApiConstants.url(ApiConstants.match)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final matches = body['matches'] as List<dynamic>;
      if (matches.isEmpty) throw Exception('No matches found');
      // Return top match
      return MatchResult.fromJson(Map<String, dynamic>.from(matches.first as Map));
    }
    throw Exception('Matching failed: ${res.statusCode}');
  }

  Future<List<Map<String, dynamic>>> discoverByTheme(
    String themeName, {
    int topK = 10,
  }) async {
    if (ApiConstants.useMock) return _mockDiscover();

    final res = await http.post(
      Uri.parse(ApiConstants.url(ApiConstants.discover)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'theme_name': themeName, 'top_k': topK}),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = body['helpers'] as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw Exception('Discover failed: ${res.statusCode}');
  }

  Future<MatchResult> _mockMatch() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return MatchResult.mock();
  }

  Future<List<Map<String, dynamic>>> _mockDiscover() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      {'helper_id': 'helper_001', 'score': 0.91},
      {'helper_id': 'helper_002', 'score': 0.84},
      {'helper_id': 'helper_003', 'score': 0.78},
    ];
  }
}
