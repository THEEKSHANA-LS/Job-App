// lib/providers/chat_provider.dart

import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';

class ChatProvider extends ChangeNotifier {
  final SocketService _socket = SocketService();

  ConversationModel?  _activeConversation;
  List<MessageModel>  _messages    = [];
  bool _loadingMessages            = false;
  String? _errorMessage;

  ConversationModel? get activeConversation => _activeConversation;
  List<MessageModel> get messages           => _messages;
  bool   get loadingMessages                => _loadingMessages;
  String? get errorMessage                  => _errorMessage;

  // ─── Connect socket ────────────────────────────────────────────────
  void connectSocket(String userId) {
    _socket.connect(userId);
  }

  // ─── Open / start a conversation with another user ─────────────────
  Future<ConversationModel?> startConversation({
    required String token,
    required String receiverId,
    required String currentUserId,
  }) async {
    final result = await ChatService.startConversation(
      token:      token,
      receiverId: receiverId,
    );

    if (result['success'] == true) {
      _activeConversation = result['conversation'] as ConversationModel;

      // Join the socket room for this conversation
      final room = SocketService.roomId(currentUserId, receiverId);
      _socket.joinRoom(room);

      notifyListeners();
      return _activeConversation;
    }
    _errorMessage = result['message'] as String?;
    notifyListeners();
    return null;
  }

  // ─── Load messages for active conversation ─────────────────────────
  Future<void> loadMessages({
    required String token,
    required String conversationId,
    required String currentUserId,
    required String otherUserId,
  }) async {
    _loadingMessages = true;
    _messages        = [];
    notifyListeners();

    final result = await ChatService.getMessages(
      token:          token,
      conversationId: conversationId,
    );

    if (result['success'] == true) {
      _messages = result['messages'] as List<MessageModel>;
    } else {
      _errorMessage = result['message'] as String?;
    }

    _loadingMessages = false;

    // Start listening for new socket messages
    _socket.offMessage();
    _socket.onMessage((data) {
      final msg = MessageModel.fromSocket(data);
      // Avoid duplicates from own sends
      _messages.add(msg);
      notifyListeners();
    });

    notifyListeners();
  }

  // ─── Send a message ────────────────────────────────────────────────
  void sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) {
    // Optimistically add to local list
    final optimistic = MessageModel(
      id:             DateTime.now().millisecondsSinceEpoch.toString(),
      text:           text,
      senderId:       senderId,
      senderName:     '',
      conversationId: _activeConversation?.id ?? '',
      createdAt:      DateTime.now().toIso8601String(),
    );
    _messages.add(optimistic);
    notifyListeners();

    // Emit via socket
    _socket.sendMessage(
      senderId:   senderId,
      receiverId: receiverId,
      message:    text,
    );
  }

  // ─── Clear when leaving chat ───────────────────────────────────────
  void clearChat() {
    _socket.offMessage();
    _activeConversation = null;
    _messages           = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _socket.offMessage();
    super.dispose();
  }
}