// lib/models/notification_model.dart

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;   // application | message | job | system
  final bool   isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:        json['_id'] ?? '',
      title:     json['title'] ?? '',
      message:   json['message'] ?? '',
      type:      json['type'] ?? 'system',
      isRead:    json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}