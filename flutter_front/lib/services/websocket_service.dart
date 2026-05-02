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
  bool _connecting = false;
  bool _intentionalClose = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectDelay = 3;
  static const int _maxReconnectDelay = 60;
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  bool get isConnected => _connected;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  void connect() {
    if (_connected || _connecting) return;

    if (_channel != null) {
      _intentionalClose = true;
      try {
        _channel?.sink.close();
      } catch (_) {}
      _channel = null;
    }

    final token = AuthService.token;
    if (token == null || token.isEmpty) return;

    _connecting = true;
    _intentionalClose = false;

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8081/ws/chat?token=$token'),
      );

      _channel!.ready.then((_) {
        _connected = true;
        _connecting = false;
        _reconnectDelay = 3;
        _startHeartbeat();
      }).catchError((error) {
        _connected = false;
        _connecting = false;
        _scheduleReconnect();
      });

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            if (json['type'] == 'PONG') return;
            _messageController.add(json);
          } catch (_) {}
        },
        onDone: () {
          final wasConnected = _connected;
          _connected = false;
          _connecting = false;
          _stopHeartbeat();
          if (wasConnected && !_intentionalClose) {
            _scheduleReconnect();
          }
        },
        onError: (_) {
          _connected = false;
          _connecting = false;
          _stopHeartbeat();
          if (!_intentionalClose) {
            _scheduleReconnect();
          }
        },
      );
    } catch (_) {
      _connected = false;
      _connecting = false;
      _scheduleReconnect();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_connected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'PING'}));
        } catch (_) {
          _connected = false;
          _stopHeartbeat();
          _scheduleReconnect();
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), () {
      if (!_connected && !_connecting) {
        connect();
      }
    });
    _reconnectDelay = (_reconnectDelay * 2).clamp(3, _maxReconnectDelay);
  }

  bool sendMessage(Map<String, dynamic> message) {
    if (!_connected || _channel == null) {
      if (!_connecting) {
        connect();
      }
      return false;
    }
    try {
      _channel!.sink.add(jsonEncode(message));
      return true;
    } catch (_) {
      _connected = false;
      _stopHeartbeat();
      _scheduleReconnect();
      return false;
    }
  }

  void disconnect() {
    _intentionalClose = true;
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _connecting = false;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _connected = false;
    _reconnectDelay = 3;
  }
}

class AppEventBus {
  static final StreamController<String> _controller = StreamController<String>.broadcast();

  static Stream<String> get stream => _controller.stream;

  static void emit(String event) {
    _controller.add(event);
  }

  static const String refreshSessions = 'refresh_sessions';
}
