import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';
import '../../errors/auth_exception.dart';
import '../storage_service.dart';

class AuthService {
  AuthService({StorageService? storageService})
    : _storage = storageService ?? StorageService();

  final StorageService _storage;

  /// Returns the stored JWT if the user previously logged in.
  Future<String?> readStoredToken() => _storage.getToken();

  /// Calls the login API, persists [access_token], and returns it.
  Future<String> login(String email, String password) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw AuthException('Email and password are required.');
    }

    final response = await http.post(
      Uri.parse(AppConstants.loginUrl),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': trimmedEmail, 'password': password}),
    );
    print(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseErrorResponse(response);
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw AuthException('Invalid login response.');
    }

    final token = decoded['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw AuthException('Invalid login response: missing access token.');
    }

    await _storage.saveToken(token);
    return token;
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  AuthException _parseErrorResponse(http.Response response) {
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.isNotEmpty) {
          return AuthException(message);
        }
      }
    } catch (_) {
      // Fall through to generic message.
    }
    return AuthException(
      'Login failed (${response.statusCode}). Please try again.',
    );
  }
}
