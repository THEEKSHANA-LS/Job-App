// lib/models/conversation_model.dart

class ConversationModel {
  final String        id;
  final List<ParticipantInfo> participants;
  final String        createdAt;
  final String?       lastMessage;
  final String?       lastMessageAt;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['participants'] as List<dynamic>? ?? [];
    return ConversationModel(
      id: json['_id'] ?? '',
      participants: rawList
          .whereType<Map<String, dynamic>>()
          .map(ParticipantInfo.fromJson)
          .toList(),
      createdAt:     json['createdAt'] ?? '',
      lastMessage:   json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] as String?,
    );
  }
}

class ParticipantInfo {
  final String  id;
  final String  name;
  final String  email;
  final String? profileImage;

  ParticipantInfo({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
  });

  factory ParticipantInfo.fromJson(Map<String, dynamic> json) => ParticipantInfo(
    id:           json['_id'] ?? '',
    name:         json['name'] ?? '',
    email:        json['email'] ?? '',
    profileImage: json['profileImage'] as String?,
  );
}