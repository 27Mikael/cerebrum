import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cerebrum_app/models/engram_models.dart';
import 'api_config.dart';

class LearningCenterApi {
  static String get baseUrl => ApiConfig.baseUrl;
  static String get learningCenterEndpoint => "$baseUrl/learn";

  /// Fetch whatever analysis is cached (chunk_diagnostics + note_overview),
  /// regardless of whether it matches the note's current version. Pass
  /// currentVersion to also get an is_current flag back so the caller can
  /// show a staleness notice instead of silently serving old content.
  static Future<Map<String, dynamic>?> getFullCachedAnalysis({
    required String bubbleId,
    required String noteId,
    double? currentVersion,
  }) async {
    final uri = Uri.parse(
      "$learningCenterEndpoint/fetch/analysis/full",
    ).replace(
      queryParameters: {
        "bubble_id": bubbleId,
        "note_id": noteId,
        if (currentVersion != null)
          "current_version": currentVersion.toString(),
      },
    );
    final response = await http.get(
      uri,
      headers: await ApiConfig.headers(json: false),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body == null ? null : body as Map<String, dynamic>;
    }

    throw Exception("Failed to fetch full analysis: ${response.statusCode}");
  }

  static Future<Map<String, dynamic>> submitMcq({
    required String engramId,
    required String userId,
    required String selectedOption,
    int targetCognitiveLevel = 1,
  }) async {
    final uri = Uri.parse(
      '$learningCenterEndpoint/engrams/mcq/$engramId/submit',
    );
    final response = await http.post(
      uri,
      headers: await ApiConfig.headers(userId: userId),
      body: jsonEncode({
        'selected_option': selectedOption,
        'target_cognitive_level': targetCognitiveLevel,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to submit MCQ (${response.statusCode}): ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> submitFlashcard({
    required String engramId,
    required String userId,
    required String selfRating, // "again" | "hard" | "good" | "easy"
    int targetCognitiveLevel = 1,
  }) async {
    final uri = Uri.parse(
      '$learningCenterEndpoint/engrams/flashcard/$engramId/submit',
    );
    final response = await http.post(
      uri,
      headers: await ApiConfig.headers(userId: userId),
      body: jsonEncode({
        'self_rating': selfRating,
        'target_cognitive_level': targetCognitiveLevel,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to submit flashcard (${response.statusCode}): ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> submitShortQuestion({
    required String engramId,
    required String userId,
    required List<Map<String, String>> responses, // [{question_id, raw_answer}]
    int targetCognitiveLevel = 1,
  }) async {
    final uri = Uri.parse(
      '$learningCenterEndpoint/engrams/short_question/$engramId/submit',
    );
    final response = await http.post(
      uri,
      headers: await ApiConfig.headers(userId: userId),
      body: jsonEncode({
        'responses': responses,
        'target_cognitive_level': targetCognitiveLevel,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to submit short question (${response.statusCode}): ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> submitLongQuestion({
    required String engramId,
    required String userId,
    required String rawAnswer,
    int targetCognitiveLevel = 1,
  }) async {
    final uri = Uri.parse(
      '$learningCenterEndpoint/engrams/long_question/$engramId/submit',
    );
    final response = await http.post(
      uri,
      headers: await ApiConfig.headers(userId: userId),
      body: jsonEncode({
        'raw_answer': rawAnswer,
        'target_cognitive_level': targetCognitiveLevel,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to submit long question (${response.statusCode}): ${response.body}',
    );
  }

  static Future<EngramListResponse> listEngrams({
    required String userId,
    String? bubbleId,
    String? noteId,
    String? state,
  }) async {
    // IMPORTANT: every one of these must be conditional. Uri.replace
    // treats a null query value as "include this key with no value"
    // (e.g. `?bubble_id`), NOT "omit the key" -- so an unconditional
    // 'bubble_id': bubbleId sends bubble_id="" to the backend when
    // bubbleId is null. FastAPI then sees bubble_id as an empty STRING,
    // not None, and the router's `elif bubble_id is not None` branch
    // fires with an empty id that matches nothing -- silently returning
    // zero engrams instead of falling through to get_all_engrams. This
    // was the bug behind the global dashboard showing "No engrams yet."
    // even though the same request via curl (bubble_id omitted
    // entirely) returned real data.
    final uri = Uri.parse('$learningCenterEndpoint/engrams/list').replace(
      queryParameters: {
        if (bubbleId != null) 'bubble_id': bubbleId,
        if (noteId != null) 'note_id': noteId,
        if (state != null) 'state': state,
      },
    );

    final response = await http.get(
      uri,
      headers: await ApiConfig.headers(json: false, userId: userId),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return EngramListResponse.fromJson(json);
    } else {
      throw Exception(
        'Failed to fetch engrams (${response.statusCode}): ${response.body}',
      );
    }
  }

  static Future<String?> runActiveAnalysis({
    required String bubbleId,
    required String filename,
  }) async {
    final uri = Uri.parse(
      "$learningCenterEndpoint/active_analysis/$bubbleId/$filename",
    );

    final response = await http.post(
      uri,
      headers: await ApiConfig.headers(json: false),
    );

    if (response.statusCode == 200) {
      final body = response.body;
      if (body.isEmpty || body == 'null') return null;

      try {
        final decoded = jsonDecode(body);
        return decoded as String?;
      } catch (_) {
        return body;
      }
    }

    throw Exception(
      "Failed to run active analysis. Status: ${response.statusCode}, Body: ${response.body}",
    );
  }

  static Future<Map<String, dynamic>?> getAnalysisStatus({
    required String bubbleId,
    required String filename,
  }) async {
    final response = await http.get(
      Uri.parse("$learningCenterEndpoint/analysis_status/$bubbleId/$filename"),
      headers: await ApiConfig.headers(json: false),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 404) return null;

    throw Exception("Failed to fetch analysis status: ${response.statusCode}");
  }
}
