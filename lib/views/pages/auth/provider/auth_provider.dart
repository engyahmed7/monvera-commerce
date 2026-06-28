import 'package:flutter/foundation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/realtime/reverb_socket_service.dart';
import '../../../../core/errors/auth_exception.dart';
import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, ReverbSocketService? reverbSocketService})
    : _authService = authService ?? AuthService(),
      _reverbSocketService = reverbSocketService ?? ReverbSocketService.instance {
    DioClient.instance.setUnauthorizedHandler(_handleUnauthorized);
  }

  final AuthService _authService;
  final ReverbSocketService _reverbSocketService;

  String? _token;
  bool _isBusy = false;

  String? get token => _token;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  bool get isBusy => _isBusy;

  Future<void> initialize() async {
    _token = await _authService.readStoredToken();
    if (isLoggedIn) {
      await _reverbSocketService.connect();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isBusy = true;
    notifyListeners();
    try {
      _token = await _authService.login(email, password);
      await _reverbSocketService.connect();
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
    await _reverbSocketService.disconnect();
    await _authService.logout();
    _token = null;
    notifyListeners();
  }

  Future<void> _handleUnauthorized() async {
    if (!isLoggedIn) return;
    await logout();
  }
}
