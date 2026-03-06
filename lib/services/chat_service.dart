import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_service.dart';

/// Chat service — wraps Socket.IO for real-time messaging + REST for history.
class ChatService {
  static io.Socket? _socket;
  static bool _isConnected = false;

  // ─── Callbacks ─────────────────────────────────────────────────
  static Function(Map<String, dynamic>)? onNewMessage;
  static Function(Map<String, dynamic>)? onTyping;
  static Function(Map<String, dynamic>)? onMessageRead;
  static Function(Map<String, dynamic>)? onUserJoined;
  static Function()? onConnected;
  static Function()? onDisconnected;

  /// Connect to Socket.IO server
  static Future<void> connect() async {
    if (_isConnected && _socket != null) return;

    final token = await ApiService.getToken();
    if (token == null) {
      debugPrint('ChatService: No token, cannot connect');
      return;
    }

    final serverUrl = ApiService.baseUrl.replaceAll('/api', '');

    _socket = io.io(serverUrl, io.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .enableAutoConnect()
      .enableReconnection()
      .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('🔌 Socket.IO connected');
      onConnected?.call();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('🔌 Socket.IO disconnected');
      onDisconnected?.call();
    });

    _socket!.on('new_message', (data) {
      debugPrint('💬 New message received');
      onNewMessage?.call(Map<String, dynamic>.from(data));
    });

    _socket!.on('typing', (data) {
      onTyping?.call(Map<String, dynamic>.from(data));
    });

    _socket!.on('message_read', (data) {
      onMessageRead?.call(Map<String, dynamic>.from(data));
    });

    _socket!.on('user_joined', (data) {
      onUserJoined?.call(Map<String, dynamic>.from(data));
    });

    _socket!.on('error', (data) {
      debugPrint('❌ Socket error: $data');
    });

    _socket!.connect();
  }

  /// Disconnect from Socket.IO
  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  /// Join a chat room
  static void joinRoom(String roomId) {
    _socket?.emit('join_room', {'room_id': roomId});
  }

  /// Leave a chat room
  static void leaveRoom(String roomId) {
    _socket?.emit('leave_room', {'room_id': roomId});
  }

  /// Send a message
  static void sendMessage({
    required String roomId,
    required String text,
    String messageType = 'text',
  }) {
    _socket?.emit('send_message', {
      'room_id': roomId,
      'text': text,
      'message_type': messageType,
    });
  }

  /// Send typing indicator
  static void sendTyping({required String roomId, required bool isTyping}) {
    _socket?.emit('typing', {
      'room_id': roomId,
      'is_typing': isTyping,
    });
  }

  /// Send read receipt
  static void sendReadReceipt(String messageId) {
    _socket?.emit('read_receipt', {'message_id': messageId});
  }

  /// Share location via chat
  static void shareLocation({
    required String roomId,
    required double lat,
    required double lng,
  }) {
    _socket?.emit('share_location', {
      'room_id': roomId,
      'lat': lat,
      'lng': lng,
    });
  }

  // ─── REST API Methods ──────────────────────────────────────────

  /// Get all chat rooms for current user
  static Future<Map<String, dynamic>> getMyRooms() async {
    return await ApiService.get('/chat/rooms');
  }

  /// Get messages for a chat room
  static Future<Map<String, dynamic>> getMessages(String roomId, {int page = 1}) async {
    return await ApiService.get('/chat/rooms/$roomId/messages', queryParams: {
      'page': page.toString(),
    });
  }

  /// Create or get a chat room for a case
  static Future<Map<String, dynamic>> getOrCreateRoom(String caseId) async {
    return await ApiService.post('/chat/rooms', body: {
      'case_id': caseId,
    });
  }

  /// Check if connected
  static bool get isConnected => _isConnected;
}
