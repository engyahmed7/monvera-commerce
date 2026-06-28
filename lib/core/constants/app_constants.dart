abstract final class AppConstants {
  static const String appName = 'MONVERA';
  static const String logoAssetPath = 'assets/images/logo2.png';

  static const String loginUrl = 'https://api.escuelajs.co/api/v1/auth/login';
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api/';
  static const String overrideBearerToken =
      '5262|d0yBxXQk5RA4BkjHCzF8ygZYlPfmrRVUNQRwjfZ21461da5f';
  // Local Reverb: host only (no port). Use 10.0.2.2 on Android emulator, not localhost.
  static const String reverbHost = 'localhost';
  static const int reverbPort = 8080;
  static const String reverbAppKey = '2jtnuhkv6kfdvgiao4we';
  static const bool reverbUseTls = false;

  // Production:
  // static const String reverbHost = 'rntls-ws.objectsdev.com';
  // static const int reverbPort = 443;
  // static const String reverbAppKey = 'testkey1';
  // static const bool reverbUseTls = true;
  static const String broadcastingAuthPath = '/broadcasting/auth';

  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeAbout = '/about';
  static const String routeCart = '/cart';
}
