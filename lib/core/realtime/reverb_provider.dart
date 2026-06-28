import 'dart:async';

import 'package:flutter/foundation.dart';

import 'chat_events.dart';
import 'reverb_socket_service.dart';

class ReverbProvider extends ChangeNotifier {
  ReverbProvider({ReverbSocketService? socketService})
    : _socketService = socketService ?? ReverbSocketService.instance {
    _messageSentSub = _socketService.onMessageSent.listen((event) {
      _lastMessageSent = event;
      notifyListeners();
    });
    _messageReadSub = _socketService.onMessageRead.listen((event) {
      _lastMessageRead = event;
      notifyListeners();
    });
  }

  final ReverbSocketService _socketService;
  StreamSubscription<ChatMessageSentEvent>? _messageSentSub;
  StreamSubscription<ChatMessageReadEvent>? _messageReadSub;

  ChatMessageSentEvent? _lastMessageSent;
  ChatMessageReadEvent? _lastMessageRead;
  String? _errorMessage;

  bool get isConnected => _socketService.isConnected;
  ChatMessageSentEvent? get lastMessageSent => _lastMessageSent;
  ChatMessageReadEvent? get lastMessageRead => _lastMessageRead;
  String? get errorMessage => _errorMessage;

  Future<void> connect() async {
    _errorMessage = null;
    try {
      await _socketService.connect();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _errorMessage = null;
    await _socketService.disconnect();
    notifyListeners();
  }

  Future<void> subscribeChatRoom(int roomId) async {
    _errorMessage = null;
    try {
      await _socketService.subscribeChatRoom(roomId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void unsubscribeChatRoom(int roomId) {
    _socketService.unsubscribeChatRoom(roomId);
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _messageSentSub?.cancel();
    await _messageReadSub?.cancel();
    super.dispose();
  }
}
