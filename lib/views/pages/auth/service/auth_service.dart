import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/auth_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/storage_service.dart';

class AuthService {
  AuthService({StorageService? storageService})
    : _storage = storageService ?? StorageService();

  final StorageService _storage;
  final Dio _dio = DioClient.instance.dio;

  Future<String?> readStoredToken() => _storage.getToken();

  Future<String> login(String email, String password) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw AuthException('Email and password are required.');
    }

    try {
      final response = await _dio.post<dynamic>(
        AppConstants.loginUrl,
        data: {'email': trimmedEmail, 'password': password},
      );

      final dynamic decoded = response.data;
      if (decoded is! Map<String, dynamic>) {
        throw AuthException('Invalid login response.');
      }

      final token = decoded['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw AuthException('Invalid login response: missing access token.');
      }

      await _storage.saveToken(token);
      return token;
    } on DioException catch (e) {
      throw _parseErrorResponse(e);
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  AuthException _parseErrorResponse(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return AuthException(message);
      }
    }

    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          final message = decoded['message'];
          if (message is String && message.isNotEmpty) {
            return AuthException(message);
          }
        }
      } catch (_) {
        return AuthException('Invalid login response: missing message.');
      }
    }

    final statusCode = error.response?.statusCode;
    return AuthException(
      'Login failed (${statusCode ?? 'network error'}). Please try again.',
    );
  }
}
