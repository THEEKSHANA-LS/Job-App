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
      final conv = ConversationModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      return {'success': true, 'conversation': conv};
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
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
      return {'success': true, 'messages': msgs};
    }
    return {'success': false, 'message': response.message};
  }
}