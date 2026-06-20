// lib/services/auth_service.dart

import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  /// Register a new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role, // jobseeker | employer
  }) async {
    final response = await ApiService.post(
      AppConstants.registerEndpoint,
      body: {
        'name':     name,
        'email':    email,
        'password': password,
        'role':     role,
      },
    );

    if (response.success && response.data != null) {
      final data    = response.data!['data'] as Map<String, dynamic>;
      final token   = data['token'] as String;
      final user    = UserModel.fromJson(data, token);
      return {'success': true, 'user': user};
    }

    return {'success': false, 'message': response.message};
  }

  /// Login an existing user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      AppConstants.loginEndpoint,
      body: {
        'email':    email,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final data  = response.data!['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user  = UserModel.fromJson(data, token);
      return {'success': true, 'user': user};
    }

    return {'success': false, 'message': response.message};
  }
}