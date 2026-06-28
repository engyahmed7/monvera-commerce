import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import 'chat_events.dart';

class ReverbSocketService {
  ReverbSocketService._internal({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  static final ReverbSocketService instance = ReverbSocketService._internal();

  final Dio _dio;
  final StreamController<ChatMessageSentEvent> _messageSentController =
      StreamController<ChatMessageSentEvent>.broadcast();
  final StreamController<ChatMessageReadEvent> _messageReadController =
      StreamController<ChatMessageReadEvent>.broadcast();
  final Set<String> _subscribedChannels = <String>{};

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  String? _socketId;
  bool _isConnecting = false;

  bool get isConnected => _socket != null && _socketId != null;
  String? get socketId => _socketId;

  Stream<ChatMessageSentEvent> get onMessageSent => _messageSentController.stream;
  Stream<ChatMessageReadEvent> get onMessageRead => _messageReadController.stream;

  Future<void> connect() async {
    if (isConnected || _isConnecting) return;
    _isConnecting = true;

    final scheme = AppConstants.reverbUseTls ? 'wss' : 'ws';
    final url = Uri(
      scheme: scheme,
      host: AppConstants.reverbHost,
      port: AppConstants.reverbPort,
      path: '/app/${AppConstants.reverbAppKey}',
    );
    debugPrint('[Reverb] connect -> $url');

    try {
      final socket = await WebSocket.connect(url.toString());
      _socket = socket;
      debugPrint('[Reverb] socket opened; waiting connection_established');
      _socketSubscription = socket.listen(
        _handleIncoming,
        onDone: _resetConnection,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[Reverb] socket error: $error\n$stackTrace');
          _resetConnection();
        },
        cancelOnError: true,
      );
    } catch (e, st) {
      debugPrint('[Reverb] connect failed: $e\n$st');
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect() async {
    _subscribedChannels.clear();
    _socketId = null;
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    await _socket?.close(WebSocketStatus.normalClosure);
    _socket = null;
  }

  Future<void> subscribeChatRoom(int roomId) async {
    await connect();
    if (_socketId == null) {
      throw StateError(
        'Socket ID not ready yet. Wait for connection_established first.',
      );
    }

    final channelName = 'private-chat.room.$roomId';
    if (_subscribedChannels.contains(channelName)) return;
    debugPrint('[Reverb] subscribe start -> $channelName');

    final auth = await _authorizeChannel(
      socketId: _socketId!,
      channelName: channelName,
    );

    _send({
      'event': 'pusher:subscribe',
      'data': {'channel': channelName, 'auth': auth},
    });
    debugPrint('[Reverb] subscribe sent -> $channelName');

    _subscribedChannels.add(channelName);
  }

  void unsubscribeChatRoom(int roomId) {
    final channelName = 'private-chat.room.$roomId';
    if (!_subscribedChannels.contains(channelName)) return;
    _send({
      'event': 'pusher:unsubscribe',
      'data': {'channel': channelName},
    });
    _subscribedChannels.remove(channelName);
  }

  Future<String> _authorizeChannel({
    required String socketId,
    required String channelName,
  }) async {
    final authEndpoint = Uri.parse(
      AppConstants.apiBaseUrl,
    ).resolve(AppConstants.broadcastingAuthPath);
    debugPrint(
      '[Reverb] auth request -> ${authEndpoint.toString()} '
      'socket_id=$socketId channel=$channelName',
    );
    final response = await _dio.post<dynamic>(
      authEndpoint.toString(),
      data: {'socket_id': socketId, 'channel_name': channelName},
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        headers: const {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );
    debugPrint(
      '[Reverb] auth response -> status=${response.statusCode} data=${response.data}',
    );

    if (response.statusCode == 302) {
      final location = response.headers.value('location');
      throw StateError(
        'Auth redirected to login (${location ?? 'unknown location'}). '
        'Bearer token is missing/invalid for this backend, or /broadcasting/auth '
        'is behind web guard instead of API auth guard.',
      );
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final auth = data['auth'] as String?;
      if (auth != null && auth.isNotEmpty) return auth;
    }

    throw StateError('Invalid /broadcasting/auth response: missing auth field.');
  }

  void _handleIncoming(dynamic raw) {
    if (raw is! String || raw.isEmpty) return;
    debugPrint('[Reverb] incoming -> $raw');

    final dynamic decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;

    final event = decoded['event'] as String?;
    final dynamic data = decoded['data'];
    if (event == null) return;

    switch (event) {
      case 'pusher:connection_established':
        _handleConnectionEstablished(data);
      case 'pusher:ping':
        debugPrint('[Reverb] ping received');
        _send({'event': 'pusher:pong', 'data': const <String, dynamic>{}});
      case 'message.sent':
      case '.message.sent':
        final payload = _asMap(data);
        if (payload != null) {
          debugPrint('[Reverb] message.sent -> $payload');
          _messageSentController.add(ChatMessageSentEvent.fromJson(payload));
        }
      case 'message.read':
      case '.message.read':
        final payload = _asMap(data);
        if (payload != null) {
          debugPrint('[Reverb] message.read -> $payload');
          _messageReadController.add(ChatMessageReadEvent.fromJson(payload));
        }
      default:
        break;
    }
  }

  void _handleConnectionEstablished(dynamic data) {
    final payload = _asMap(data);
    final socketId = payload?['socket_id'] as String?;
    if (socketId != null && socketId.isNotEmpty) {
      _socketId = socketId;
      debugPrint('[Reverb] connected socket_id=$_socketId');
    }
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is String && value.isNotEmpty) {
      final dynamic parsed = jsonDecode(value);
      if (parsed is Map<String, dynamic>) return parsed;
    }
    return null;
  }

  void _send(Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket == null) return;
    debugPrint('[Reverb] outgoing -> ${jsonEncode(payload)}');
    socket.add(jsonEncode(payload));
  }

  void _resetConnection() {
    debugPrint('[Reverb] reset connection state');
    _socketId = null;
    _socket = null;
    _socketSubscription = null;
    _subscribedChannels.clear();
  }
}
