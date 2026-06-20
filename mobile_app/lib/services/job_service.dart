// lib/services/job_service.dart

import '../constants/app_constants.dart';
import '../models/job_model.dart';
import 'api_service.dart';

class JobService {
  /// GET /api/jobs — public, supports ?category=&location=&jobType=
  static Future<Map<String, dynamic>> getAllJobs({
    String? category,
    String? location,
    String? jobType,
  }) async {
    final params = <String, String>{};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (location  != null && location.isNotEmpty)  params['location']  = location;
    if (jobType   != null && jobType.isNotEmpty)   params['jobType']   = jobType;

    final query   = params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
    final response = await ApiService.get('${AppConstants.jobsEndpoint}$query');

    if (response.success && response.data != null) {
      final list = response.data!['data'] as List<dynamic>;
      final jobs = list.map((j) => JobModel.fromJson(j as Map<String, dynamic>)).toList();
      return {'success': true, 'jobs': jobs};
    }
    return {'success': false, 'message': response.message};
  }

  /// GET /api/jobs/:id
  static Future<Map<String, dynamic>> getJobById(String jobId) async {
    final response = await ApiService.get('${AppConstants.jobsEndpoint}/$jobId');
    if (response.success && response.data != null) {
      final job = JobModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      return {'success': true, 'job': job};
    }
    return {'success': false, 'message': response.message};
  }

  /// POST /api/jobs — employer/admin only
  static Future<Map<String, dynamic>> createJob({
    required String token,
    required String title,
    required String description,
    required String category,
    required String jobType,
    required double salary,
    required String location,
  }) async {
    final response = await ApiService.post(
      AppConstants.jobsEndpoint,
      token: token,
      body: {
        'title':       title,
        'description': description,
        'category':    category,
        'jobType':     jobType,
        'salary':      salary,
        'location':    location,
      },
    );
    if (response.success && response.data != null) {
      final job = JobModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      return {'success': true, 'job': job};
    }
    return {'success': false, 'message': response.message};
  }

  /// PUT /api/jobs/:id — employer/admin only
  static Future<Map<String, dynamic>> updateJob({
    required String token,
    required String jobId,
    required Map<String, dynamic> data,
  }) async {
    final response = await ApiService.put(
      '${AppConstants.jobsEndpoint}/$jobId',
      token: token,
      body:  data,
    );
    if (response.success && response.data != null) {
      final job = JobModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      return {'success': true, 'job': job};
    }
    return {'success': false, 'message': response.message};
  }

  /// DELETE /api/jobs/:id — employer/admin only
  static Future<Map<String, dynamic>> deleteJob({
    required String token,
    required String jobId,
  }) async {
    final response = await ApiService.delete(
      '${AppConstants.jobsEndpoint}/$jobId',
      token: token,
    );
    return {'success': response.success, 'message': response.message};
  }
}