// lib/providers/notification_provider.dart

import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool    _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int  get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications(String token) async {
    _isLoading = true;
    notifyListeners();

    final result = await NotificationService.getNotifications(token);
    if (result['success'] == true) {
      _notifications = result['notifications'] as List<NotificationModel>;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead({required String token, required String notificationId}) async {
    final result = await NotificationService.markAsRead(
      token:          token,
      notificationId: notificationId,
    );
    if (result['success'] == true) {
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        final n = _notifications[idx];
        _notifications[idx] = NotificationModel(
          id:        n.id,
          title:     n.title,
          message:   n.message,
          type:      n.type,
          isRead:    true,
          createdAt: n.createdAt,
        );
        notifyListeners();
      }
    }
  }

  Future<void> markAllRead(String token) async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    for (final n in unread) {
      await markAsRead(token: token, notificationId: n.id);
    }
  }
}