// lib/services/saved_job_service.dart

import '../constants/app_constants.dart';
import '../models/saved_job_model.dart';
import 'api_service.dart';

class SavedJobService {
  static Future<Map<String, dynamic>> getSavedJobs(String token) async {
    final response = await ApiService.get(AppConstants.savedJobsEndpoint, token: token);
    if (response.success && response.data != null) {
      final list = response.data!['data'] as List<dynamic>;
      final jobs = list.map((j) => SavedJobModel.fromJson(j as Map<String, dynamic>)).toList();
      return {'success': true, 'savedJobs': jobs};
    }
    return {'success': false, 'message': response.message};
  }

  static Future<Map<String, dynamic>> saveJob({
    required String token,
    required String jobId,
  }) async {
    final response = await ApiService.post(
      AppConstants.savedJobsEndpoint,
      token: token,
      body:  {'jobId': jobId},
    );
    return {'success': response.success, 'message': response.message};
  }

  static Future<Map<String, dynamic>> removeSavedJob({
    required String token,
    required String savedJobId,
  }) async {
    final response = await ApiService.delete(
      '${AppConstants.savedJobsEndpoint}/$savedJobId',
      token: token,
    );
    return {'success': response.success, 'message': response.message};
  }
}