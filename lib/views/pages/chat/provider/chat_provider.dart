import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/realtime/chat_events.dart';
import '../../../../core/realtime/reverb_socket_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({ReverbSocketService? socketService, Dio? dio})
    : _socketService = socketService ?? ReverbSocketService.instance,
      _dio = dio ?? DioClient.instance.dio {
    _messageSentSub = _socketService.onMessageSent.listen((event) {
      if (_roomId != null && event.chatRoomId == _roomId) {
        _messages.add(event);
        notifyListeners();
      }
    });
    _messageReadSub = _socketService.onMessageRead.listen((event) {
      if (_roomId != null && event.chatRoomId == _roomId) {
        _lastReadEvent = event;
        notifyListeners();
      }
    });
  }

  final ReverbSocketService _socketService;
  final Dio _dio;

  StreamSubscription<ChatMessageSentEvent>? _messageSentSub;
  StreamSubscription<ChatMessageReadEvent>? _messageReadSub;

  int? _roomId;
  bool _isBusy = false;
  String? _error;
  ChatMessageReadEvent? _lastReadEvent;
  String? _token;
  final List<ChatMessageSentEvent> _messages = <ChatMessageSentEvent>[];

  int? get roomId => _roomId;
  bool get isBusy => _isBusy;
  String? get error => _error;
  bool get isConnected => _socketService.isConnected;
  ChatMessageReadEvent? get lastReadEvent => _lastReadEvent;
  List<ChatMessageSentEvent> get messages => List.unmodifiable(_messages);
  String? get token => _token;

  Future<void> initialize() async {
    // _token = await StorageService().getToken();
    _token = '3826|NrGZQ29OqAPcFdYFipzOTNGR7G1VC68t9GSVAIhr85da9e87';
    notifyListeners();
  }

  Future<void> openRoomById(int roomId) async {
    _setBusy(true);
    _error = null;
    try {
      debugPrint('[Chat] openRoomById -> roomId=$roomId');
      await _socketService.connect();
      await _socketService.subscribeChatRoom(roomId);
      _roomId = roomId;
      _messages.clear();
      _lastReadEvent = null;
    } on DioException catch (e) {
      debugPrint(
        '[Chat] openRoomById DioException -> status=${e.response?.statusCode} '
        'data=${e.response?.data} error=${e.message}',
      );
      _error =
          'Failed to open room: ${e.message} (status: ${e.response?.statusCode ?? 'n/a'})';
    } catch (e, st) {
      debugPrint('[Chat] openRoomById error -> $e\n$st');
      _error = 'Failed to open room: $e';
    } finally {
      _setBusy(false);
      notifyListeners();
    }
  }

  Future<void> openRoomFromRental(int rentalId) async {
    _setBusy(true);
    _error = null;
    try {
      final endpoint = Uri.parse(
        AppConstants.apiBaseUrl,
      ).resolve('/api/v1/chat/rentals/$rentalId/room');
      debugPrint(
        '[Chat] openRoomFromRental endpoint -> ${endpoint.toString()}',
      );
      final response = await _dio.post<dynamic>(
        endpoint.toString(),
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
          headers: const {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );
      if (response.statusCode == 302) {
        throw StateError(
          'Room endpoint redirected to login. Token is not authorized for this API.',
        );
      }
      debugPrint(
        '[Chat] openRoomFromRental response -> status=${response.statusCode} '
        'data=${response.data}',
      );
      final roomId = _extractRoomId(response.data);
      if (roomId == null) {
        throw StateError('Room ID was not found in response payload.');
      }
      await _socketService.connect();
      await _socketService.subscribeChatRoom(roomId);
      _roomId = roomId;
      _messages.clear();
      _lastReadEvent = null;
    } on DioException catch (e) {
      debugPrint(
        '[Chat] openRoomFromRental DioException -> status=${e.response?.statusCode} '
        'data=${e.response?.data} error=${e.message}',
      );
      _error =
          'Failed to open room from rental: ${e.message} (status: ${e.response?.statusCode ?? 'n/a'})';
    } catch (e, st) {
      debugPrint('[Chat] openRoomFromRental error -> $e\n$st');
      _error = 'Failed to open room from rental: $e';
    } finally {
      _setBusy(false);
      notifyListeners();
    }
  }

  void leaveCurrentRoom() {
    final roomId = _roomId;
    if (roomId != null) {
      _socketService.unsubscribeChatRoom(roomId);
    }
    _roomId = null;
    _messages.clear();
    _lastReadEvent = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  int? _extractRoomId(dynamic data) {
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is Map<String, dynamic>) {
        final id = payload['id'];
        if (id is int) return id;
        if (id is String) return int.tryParse(id);
      }
    }
    return null;
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _messageSentSub?.cancel();
    await _messageReadSub?.cancel();
    super.dispose();
  }
}
