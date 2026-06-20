// lib/services/application_service.dart

import '../constants/app_constants.dart';
import '../models/application_model.dart';
import 'api_service.dart';

class ApplicationService {
  /// POST /api/applications — jobseeker applies
  static Future<Map<String, dynamic>> applyForJob({
    required String token,
    required String jobId,
    String coverLetter = '',
  }) async {
    final response = await ApiService.post(
      AppConstants.applicationsEndpoint,
      token: token,
      body:  {'jobId': jobId, 'coverLetter': coverLetter},
    );
    return {'success': response.success, 'message': response.message};
  }

  /// GET /api/applications/my-applications
  static Future<Map<String, dynamic>> getMyApplications(String token) async {
    final response = await ApiService.get(
      AppConstants.myApplicationsEndpoint,
      token: token,
    );
    if (response.success && response.data != null) {
      final list = response.data!['data'] as List<dynamic>;
      final apps = list
          .map((a) => ApplicationModel.fromJson(a as Map<String, dynamic>))
          .toList();
      return {'success': true, 'applications': apps};
    }
    return {'success': false, 'message': response.message};
  }

  /// DELETE /api/applications/:id — withdraw
  static Future<Map<String, dynamic>> withdrawApplication({
    required String token,
    required String applicationId,
  }) async {
    final response = await ApiService.delete(
      '${AppConstants.applicationsEndpoint}/$applicationId',
      token: token,
    );
    return {'success': response.success, 'message': response.message};
  }

  /// GET /api/applications/job/:jobId — employer views applicants
  static Future<Map<String, dynamic>> getApplicantsForJob({
    required String token,
    required String jobId,
  }) async {
    final response = await ApiService.get(
      '${AppConstants.applicationsEndpoint}/job/$jobId',
      token: token,
    );
    if (response.success && response.data != null) {
      final list = response.data!['data'] as List<dynamic>;
      final apps = list
          .map((a) => ApplicationModel.fromJson(a as Map<String, dynamic>))
          .toList();
      return {'success': true, 'applications': apps};
    }
    return {'success': false, 'message': response.message};
  }

  /// PUT /api/applications/:id/status — employer updates status
  static Future<Map<String, dynamic>> updateStatus({
    required String token,
    required String applicationId,
    required String status,
  }) async {
    final response = await ApiService.put(
      '${AppConstants.applicationsEndpoint}/$applicationId/status',
      token: token,
      body:  {'status': status},
    );
    return {'success': response.success, 'message': response.message};
  }
}