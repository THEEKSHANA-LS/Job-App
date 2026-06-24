// lib/services/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  // ─── GET /api/users/profile ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await ApiService.get(
      AppConstants.userProfileEndpoint,
      token: token,
    );
    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data, token);
      return {'success': true, 'user': user};
    }
    return {'success': false, 'message': response.message};
  }

  // ─── PUT /api/users/profile ──────────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String phone,
  }) async {
    final response = await ApiService.put(
      AppConstants.userProfileEndpoint,
      token: token,
      body:  {'name': name, 'phone': phone},
    );
    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data, token);
      return {'success': true, 'user': user};
    }
    return {'success': false, 'message': response.message};
  }

  // ─── PUT /api/users/profile/skills ───────────────────────────────────
  static Future<Map<String, dynamic>> updateSkills({
    required String       token,
    required List<String> skills,
  }) async {
    final response = await ApiService.put(
      '${AppConstants.userProfileEndpoint}/skills',
      token: token,
      body:  {'skills': skills},
    );
    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data, token);
      return {'success': true, 'user': user};
    }
    return {'success': false, 'message': response.message};
  }

  // ─── POST /api/users/upload-cv  (multipart) ──────────────────────────
  static Future<Map<String, dynamic>> uploadCV({
    required String token,
    required String filePath,
  }) async {
    try {
      final uri     = Uri.parse('${AppConstants.baseUrl}${AppConstants.uploadCvEndpoint}');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('cv', filePath));

      final streamed = await request.send();
      final res      = await http.Response.fromStream(streamed);
      final body     = jsonDecode(res.body) as Map<String, dynamic>;

      if (body['success'] == true) {
        return {'success': true, 'cvUrl': body['data']};
      }
      return {'success': false, 'message': body['message'] ?? 'Upload failed'};
    } catch (e) {
      return {'success': false, 'message': 'Upload error: $e'};
    }
  }
}