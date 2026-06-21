// lib/models/message_model.dart

class MessageModel {
  final String  id;
  final String  text;
  final String  senderId;
  final String  senderName;
  final String  conversationId;
  final String  createdAt;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.conversationId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    final senderId   = sender is Map ? (sender['_id'] ?? '') : (sender ?? '');
    final senderName = sender is Map ? (sender['name'] ?? '') : '';

    return MessageModel(
      id:             json['_id'] ?? '',
      text:           json['text'] ?? '',
      senderId:       senderId.toString(),
      senderName:     senderName.toString(),
      conversationId: json['conversation'] is String
          ? json['conversation']
          : (json['conversation']?['_id'] ?? ''),
      createdAt:      json['createdAt'] ?? '',
    );
  }

  // For socket-received messages (no DB id yet)
  factory MessageModel.fromSocket(Map<String, dynamic> data) {
    return MessageModel(
      id:             DateTime.now().millisecondsSinceEpoch.toString(),
      text:           data['message'] ?? '',
      senderId:       data['senderId'] ?? '',
      senderName:     '',
      conversationId: '',
      createdAt:      (data['createdAt'] ?? DateTime.now()).toString(),
    );
  }
}