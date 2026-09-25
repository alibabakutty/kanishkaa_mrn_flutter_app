import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'notification_service.dart';

class WebSocketService {
  late StompClient _stompClient;
  bool _connected = false;
  bool get isConnected => _connected;

  void connect({String? jwtToken}) {
    if (_connected) return;

    final Map<String, String> headers = (jwtToken != null && jwtToken.isNotEmpty)
        ? {'Authorization': 'Bearer $jwtToken'}
        : {};

    _stompClient = StompClient(
      // FIXED: Use standard StompConfig (NOT StompConfig.sockJS)
      config: StompConfig(
        // FIXED: Pure WebSocket schema (ws://)
        url: 'ws://192.232.33.53:8086/ws',
        onConnect: _onConnect,
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        onWebSocketError: (dynamic error) => print('WebSocket error: $error'),
        onStompError: (StompFrame frame) => print('STOMP error: ${frame.body}'),
        onDisconnect: (StompFrame frame) {
          _connected = false;
          print('Disconnected from WebSocket server');
        },
      ),
    );
    _stompClient.activate();
  }

  void _onConnect(StompFrame frame) {
    _connected = true;
    print('Connected to WebSocket server');

    _stompClient.subscribe(
      destination: '/topic/orders',
      callback: (StompFrame frame) {
        if (frame.body == null) return;

        try {
          final Map<String, dynamic> data = jsonDecode(frame.body!);
          final String orderNumber = data['orderNumber']?.toString() ?? 'N/A';
          final String message =
              data['message']?.toString() ?? 'Order created successfully!';

          // Trigger local notification banner & sound
          NotificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: 'Order Updated: $orderNumber',
            body: message,
          );
        } catch (e) {
          print('Error parsing WebSocket payload: $e');
        }
      },
    );
  }

  void disconnect() {
    if (_connected) {
      _stompClient.deactivate();
      _connected = false;
      print('Disconnected from WebSocket server');
    }
  }
}