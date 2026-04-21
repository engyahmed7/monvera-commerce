import 'package:dio/dio.dart';

import '../services/storage_service.dart';

typedef UnauthorizedHandler = Future<void> Function();

class DioClient {
  DioClient._internal({StorageService? storageService})
    : _storage = storageService ?? StorageService(),
      dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: const {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isHandlingUnauthorized) {
            _isHandlingUnauthorized = true;
            try {
              await _storage.deleteToken();
              final callback = _onUnauthorized;
              if (callback != null) {
                await callback();
              }
            } finally {
              _isHandlingUnauthorized = false;
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static final DioClient instance = DioClient._internal();

  final StorageService _storage;
  final Dio dio;

  UnauthorizedHandler? _onUnauthorized;
  bool _isHandlingUnauthorized = false;

  void setUnauthorizedHandler(UnauthorizedHandler handler) {
    _onUnauthorized = handler;
  }
}
