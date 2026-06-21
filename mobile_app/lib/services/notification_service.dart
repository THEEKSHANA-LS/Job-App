// lib/services/notification_service.dart

import '../constants/app_constants.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  static Future<Map<String, dynamic>> getNotifications(String token) async {
    final response = await ApiService.get(AppConstants.notificationsEndpoint, token: token);
    if (response.success && response.data != null) {
      final list = response.data!['data'] as List<dynamic>;
      final notifications = list
          .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
          .toList();
      return {'success': true, 'notifications': notifications};
    }
    return {'success': false, 'message': response.message};
  }

  static Future<Map<String, dynamic>> markAsRead({
    required String token,
    required String notificationId,
  }) async {
    final response = await ApiService.put(
      '${AppConstants.notificationsEndpoint}/$notificationId/read',
      token: token,
    );
    return {'success': response.success, 'message': response.message};
  }
}