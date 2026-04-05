/// Thrown when authentication fails or the API returns an error payload.
class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
