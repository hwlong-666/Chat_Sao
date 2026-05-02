import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'auth_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _connected = false;

  bool get isConnected => _connected;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  void connect() {
    if (_connected) return;

    final token = AuthService.token;
    if (token == null || token.isEmpty) return;

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8081/ws/chat?token=$token'),
      );

      _connected = true;

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            _messageController.add(json);
          } catch (_) {}
        },
        onDone: () {
          _connected = false;
          Future.delayed(const Duration(seconds: 3), () {
            if (!_connected) connect();
          });
        },
        onError: (_) {
          _connected = false;
        },
      );
    } catch (_) {
      _connected = false;
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_connected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _connected = false;
  }
}
