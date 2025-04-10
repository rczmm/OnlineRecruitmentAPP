import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zhaopingapp/features/chat/data/models/chat_message_model.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

class ChatServiceImplementation {
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
    _channel?.sink.close();
    _streamSubscription?.cancel();
    _reconnectTimer?.cancel();

    try {
      String wsUrl = '$_websocketBaseUrl?userId=$_userId';
      if (_token.isNotEmpty) {
        wsUrl += '&token=$_token';
      }

      debugPrint('Connecting to: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _streamSubscription = _channel!.stream.listen(
        _onMessageReceived,
        onError: _onWebSocketError,
        onDone: _onWebSocketDone,
        cancelOnError: true,
      );

      _updateStatus(ConnectionStatus.connected);
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      _onWebSocketError(e);
    }
  }

  void _onMessageReceived(dynamic message) {
    try {
      final decodedMessage = jsonDecode(message as String);

      final senderId = decodedMessage['senderId']?.toString();
      if (senderId == null) {
        debugPrint('Received message without senderId: $message');
        return;
      }

      if (senderId == _peerId || senderId == _userId) {
        final chatMessage = ChatMessageModel.fromJson(
          decodedMessage,
          _userId,
          _peerName,
          _myAvatar,
          _peerAvatar,
        );
        _messageController.add(chatMessage);
      }
    } catch (e) {
      debugPrint('Error processing message: $e');
    }
  }

  void _onWebSocketError(dynamic error) {
    debugPrint('WebSocket Error: $error');
    _updateStatus(ConnectionStatus.error);
    _scheduleReconnect();
  }

  void _onWebSocketDone() {
    if (_currentStatus != ConnectionStatus.disconnected) {
      _updateStatus(ConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_currentStatus == ConnectionStatus.disconnected) return;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_currentStatus != ConnectionStatus.connected) {
        _attemptConnection();
      }
    });
  }

  void sendMessage(String recipientId, String text) {
    if (_channel == null || _currentStatus != ConnectionStatus.connected) {
      throw Exception('Not connected');
    }

    final message = {
      'recipientId': recipientId,
      'text': text,
      'senderId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('Send failed: $e');
    }
  }

  void sendFileMessage({
    required String recipientId,
    required String fileName,
    required String fileUrl,
    String? text,
  }) {
    if (_channel == null || _currentStatus != ConnectionStatus.connected) {
      throw Exception('Not connected');
    }

    final message = {
      'type': 'file',
      'recipientId': recipientId,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'text': text ?? '发送了附件: $fileName',
      'senderId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('Error sending file message: $e');
      throw Exception('Send failed: $e');
    }
  }

  void _updateStatus(ConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _updateStatus(ConnectionStatus.disconnected);
    _streamSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}