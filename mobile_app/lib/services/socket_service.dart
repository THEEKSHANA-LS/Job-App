// lib/services/socket_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';

typedef MessageCallback = void Function(Map<String, dynamic> data);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  // ─── Connect ──────────────────────────────────────────────────────────
  void connect(String userId) {
    if (isConnected) return;

    _socket = IO.io(
      // Strip "/api" from base URL — socket connects to the root server
      AppConstants.baseUrl.replaceAll('/api', ''),
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Socket connected');
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    _socket!.onConnectError((err) {
      print('Socket connect error: $err');
    });
  }

  // ─── Join a room ──────────────────────────────────────────────────────
  void joinRoom(String roomId) {
    _socket?.emit('join_room', roomId);
  }

  // ─── Send a message via socket ────────────────────────────────────────
  void sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) {
    _socket?.emit('send_message', {
      'senderId':   senderId,
      'receiverId': receiverId,
      'message':    message,
    });
  }

  // ─── Listen for incoming messages ────────────────────────────────────
  void onMessage(MessageCallback callback) {
    _socket?.on('receive_message', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void offMessage() {
    _socket?.off('receive_message');
  }

  // ─── Disconnect ───────────────────────────────────────────────────────
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  // ─── Build consistent room ID (must match backend logic) ─────────────
  static String roomId(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return ids.join('_');
  }
}