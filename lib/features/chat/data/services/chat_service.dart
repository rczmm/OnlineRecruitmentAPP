import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zhaopingapp/features/chat/data/models/chat_message_model.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

class ChatService {
  final String _websocketBaseUrl = 'ws://127.0.0.1:8088/chat';
  final Duration _reconnectDelay = const Duration(seconds: 5);

  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;
  Timer? _reconnectTimer;

  String _userId = '';
  String _token = '';
  String _peerId = '';
  String _peerName = '';
  String _myAvatar = '';
  String _peerAvatar = '';

  final _messageController = StreamController<ChatMessageModel>.broadcast();

  Stream<ChatMessageModel> get messageStream => _messageController.stream;

  final _statusController = StreamController<ConnectionStatus>.broadcast();

  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;

  void connect({
    required String userId,
    required String? token,
    required String peerId,
    required String peerName,
    required String myAvatar,
    required String peerAvatar,
  }) {
    _userId = userId;
    _token = token ?? '';
    _peerId = peerId;
    _peerName = peerName;
    _myAvatar = myAvatar;
    _peerAvatar = peerAvatar;

    if (_currentStatus == ConnectionStatus.connected ||
        _currentStatus == ConnectionStatus.connecting) {
      debugPrint('Already connected or connecting.');
      return;
    }

    _updateStatus(ConnectionStatus.connecting);
    _attemptConnection();
  }

  void _attemptConnection() {
    _channel?.sink.close(WebSocketStatus.goingAway); // Close existing if any
    _streamSubscription?.cancel();
    _reconnectTimer?.cancel();

    if (_userId.isEmpty) {
      debugPrint('Cannot connect without userId.');
      _updateStatus(ConnectionStatus.error);
      return;
    }

    try {
      String wsUrl = '$_websocketBaseUrl?userId=$_userId';
      if (_token.isNotEmpty) {
        wsUrl += '&token=$_token';
      }

      debugPrint('Connecting to: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      debugPrint('WebSocket connection initiated.');

      _streamSubscription = _channel!.stream.listen(
        _onMessageReceived,
        onError: _onWebSocketError,
        onDone: _onWebSocketDone,
        cancelOnError: true,
      );

      // Consider adding a timeout for connection attempt
      // If connection is successful, the backend might send a confirmation or first message
      // For now, assume connection is established quickly if no immediate error
      // A better approach is a handshake message or timeout.
      _updateStatus(
          ConnectionStatus.connected); // Optimistically set to connected
    } catch (e) {
      debugPrint('WebSocket connection failed to initiate: $e');
      _onWebSocketError(e); // Treat initiation error as a WebSocket error
    }
  }

  void _onMessageReceived(dynamic message) {
    debugPrint('Received raw message: $message');
    try {
      final decodedMessage = jsonDecode(message as String);

      final senderId = decodedMessage['senderId']?.toString();

      if (senderId == null) {
        debugPrint('Received message without senderId: $message');
        return;
      }

      // Filter messages: only process messages from the peer or self
      if (senderId == _peerId || senderId == _userId) {
        final chatMessage = ChatMessageModel.fromJson(
            decodedMessage, _userId, _peerName, _myAvatar, _peerAvatar);
        _messageController.add(chatMessage);
      } else {
        debugPrint(
            'Received message from unexpected sender: $senderId, ignoring.');
      }
    } catch (e) {
      debugPrint('Error decoding message: $e');
      debugPrint('Raw message content: $message');
      // Decide if you want to notify UI about decoding errors
    }
  }

  void _onWebSocketError(dynamic error) {
    debugPrint('WebSocket Error: $error');
    _updateStatus(ConnectionStatus.error);
    _channel = null; // Ensure channel is null on error
    _scheduleReconnect();
  }

  void _onWebSocketDone() {
    debugPrint('WebSocket connection closed.');
    // Only schedule reconnect if the closure wasn't intentional
    if (_currentStatus != ConnectionStatus.disconnected) {
      _updateStatus(ConnectionStatus.error); // Treat unexpected close as error
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_currentStatus == ConnectionStatus.disconnected) {
      // Don't reconnect if disconnect was called explicitly
      return;
    }
    _reconnectTimer?.cancel();
    debugPrint(
        'Scheduling reconnection in ${_reconnectDelay.inSeconds} seconds...');
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_currentStatus != ConnectionStatus.connected) {
        debugPrint("Attempting to reconnect...");
        _attemptConnection();
      }
    });
  }

  void sendMessage(String recipientId, String text) {
    if (_channel == null || _currentStatus != ConnectionStatus.connected) {
      debugPrint('Cannot send message: WebSocket not connected.');
      // Optionally notify UI about send failure
      throw Exception('Not connected'); // Let caller handle UI feedback
    }

    final message = {
      'recipientId': recipientId,
      'text': text,
      'senderId': _userId, // Good practice to include senderId explicitly
      'timestamp': DateTime.now().toIso8601String(), // Add timestamp
    };
    final jsonMessage = jsonEncode(message);

    try {
      debugPrint('Sending message: $jsonMessage');
      _channel!.sink.add(jsonMessage);
    } catch (e) {
      debugPrint("Error sending message: $e");
      // Consider triggering reconnect or notifying UI
      throw Exception('Send failed: $e');
    }
  }

  void sendFileMessage(
      {required String recipientId,
      required String fileName,
      required String fileUrl,
      String? text // Optional text accompanying the file
      }) {
    if (_channel == null || _currentStatus != ConnectionStatus.connected) {
      debugPrint('Cannot send file message: WebSocket not connected.');
      throw Exception('Not connected');
    }

    final message = {
      'type': 'file', // Important: Specify message type
      'recipientId': recipientId,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'text': text ?? '发送了附件: $fileName', // Default text
      'senderId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    final jsonMessage = jsonEncode(message);

    try {
      debugPrint('Sending file message: $jsonMessage');
      _channel!.sink.add(jsonMessage);
    } catch (e) {
      debugPrint("Error sending file message: $e");
      throw Exception('Send failed: $e');
    }
  }

  void disconnect() {
    debugPrint('Disconnecting WebSocket...');
    _reconnectTimer?.cancel();
    _updateStatus(ConnectionStatus.disconnected);
    _streamSubscription?.cancel();
    _channel?.sink.close(WebSocketStatus.normalClosure, 'User disconnected');
    _channel = null;
  }

  void _updateStatus(ConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      debugPrint("Connection Status: $status");
    }
  }

  void dispose() {
    disconnect(); // Ensure cleanup on dispose
    _messageController.close();
    _statusController.close();
  }
}

// Define standard WebSocket close codes if not available
class WebSocketStatus {
  static const int normalClosure = 1000;
  static const int goingAway = 1001;
}
