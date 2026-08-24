sealed class AuthException implements Exception {
  const AuthException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class AuthConfigurationException extends AuthException {
  const AuthConfigurationException(super.message, [super.cause]);
}

final class AuthCancelledException extends AuthException {
  const AuthCancelledException([
    super.message = 'Authentication was cancelled.',
    super.cause,
  ]);
}

final class AuthInteractionRequiredException extends AuthException {
  const AuthInteractionRequiredException([
    super.message = 'Interactive authentication is required.',
    super.cause,
  ]);
}

final class AuthUnavailableException extends AuthException {
  const AuthUnavailableException(super.message, [super.cause]);
}

final class AuthUnexpectedException extends AuthException {
  const AuthUnexpectedException(super.message, [super.cause]);
}
