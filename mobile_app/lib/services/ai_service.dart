// lib/services/ai_service.dart

import 'dart:convert';
import '../constants/app_constants.dart';
import '../models/job_model.dart';
import 'api_service.dart';

class AiService {
  /// GET /api/ai/recommendations — jobseeker only
  static Future<Map<String, dynamic>> getRecommendations(String token) async {
    final response = await ApiService.get(
      AppConstants.aiRecommendationsEndpoint,
      token: token,
    );

    if (response.success && response.data != null) {
      final raw = response.data!['recommendations'];
      List<JobModel> jobs = [];

      if (raw is List) {
        jobs = raw
            .whereType<Map<String, dynamic>>()
            .map(JobModel.fromJson)
            .toList();
      } else if (raw is String) {
        try {
          final cleaned = raw
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
          final decoded = jsonDecode(cleaned);
          if (decoded is List) {
            jobs = decoded
                .whereType<Map<String, dynamic>>()
                .map(JobModel.fromJson)
                .toList();
          }
        } catch (_) {
          return {'success': true, 'raw': raw, 'jobs': <JobModel>[]};
        }
      }
      return {'success': true, 'jobs': jobs, 'raw': raw};
    }
    return {'success': false, 'message': response.message};
  }
}