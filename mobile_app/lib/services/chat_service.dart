// lib/services/chat_service.dart

import '../constants/app_constants.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'api_service.dart';

class ChatService {
  /// POST /api/chat/conversation — start or get existing conversation
  static Future<Map<String, dynamic>> startConversation({
    required String token,
    required String receiverId,
  }) async {
    final response = await ApiService.post(
      AppConstants.chatConversationEndpoint,
      token: token,
      body:  {'receiverId': receiverId},
    );
    if (response.success && response.data != null) {
      final raw = response.data!['data'];
      if (raw is Map<String, dynamic>) {
        return {'success': true, 'conversation': ConversationModel.fromJson(raw)};
      }
    }
    return {'success': false, 'message': response.message};
  }

  /// GET /api/chat/conversations — list all conversations for current user
  static Future<Map<String, dynamic>> getMyConversations(String token) async {
    final response = await ApiService.get(
      AppConstants.chatConversationsEndpoint,
      token: token,
    );
    if (response.success && response.data != null) {
      final list = response.data!['data'] as List<dynamic>;
      final convs = list
          .whereType<Map<String, dynamic>>()
          .map(ConversationModel.fromJson)
          .toList();
      return {'success': true, 'conversations': convs};
    }
    return {'success': false, 'message': response.message};
  }

  /// GET /api/chat/messages/:conversationId
  static Future<Map<String, dynamic>> getMessages({
    required String token,
    required String conversationId,
  }) async {
    final response = await ApiService.get(
      '${AppConstants.chatMessagesEndpoint}/$conversationId',
      token: token,
    );
    if (response.success && response.data != null) {
      final list = response.data!['data'] as List<dynamic>;
      final msgs = list
          .whereType<Map<String, dynamic>>()
          .map(MessageModel.fromJson)
          .toList();
      return {'success': true, 'messages': msgs};
    }
    return {'success': false, 'message': response.message};
  }
}