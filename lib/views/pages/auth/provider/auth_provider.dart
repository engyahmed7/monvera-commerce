import 'package:flutter/foundation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/auth_exception.dart';
import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    DioClient.instance.setUnauthorizedHandler(_handleUnauthorized);
  }

  final AuthService _authService;

  String? _token;
  bool _isBusy = false;

  String? get token => _token;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  bool get isBusy => _isBusy;

  Future<void> initialize() async {
    _token = await _authService.readStoredToken();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isBusy = true;
    notifyListeners();
    try {
      _token = await _authService.login(email, password);
    } on AuthException {
      rethrow;
    } catch (e, st) {
      debugPrint('Login error: $e\n$st');
      throw AuthException('Could not reach the server. Check your connection.');
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    notifyListeners();
  }

  Future<void> _handleUnauthorized() async {
    if (!isLoggedIn) return;
    await logout();
  }
}
