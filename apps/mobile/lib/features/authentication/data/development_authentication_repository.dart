import '../domain/authentication_repository.dart';
import '../domain/portal_user.dart';

/// Development-only authentication repository.
///
/// This implementation does not contact Microsoft Entra ID and does not
/// create, store, or return authentication tokens.
///
/// It allows the authentication shell and routing behavior to be developed
/// before the production Microsoft authentication configuration is available.
final class DevelopmentAuthenticationRepository
    implements AuthenticationRepository {
  DevelopmentAuthenticationRepository({
    this.operationDelay = const Duration(milliseconds: 400),
  });

  /// Artificial delay used to make loading states visible during development.
  final Duration operationDelay;

  PortalUser? _currentUser;

  @override
  Future<PortalUser?> restoreSession() async {
    await Future<void>.delayed(operationDelay);

    return _currentUser;
  }

  @override
  Future<PortalUser> signIn() async {
    await Future<void>.delayed(operationDelay);

    const user = PortalUser(
      id: 'development-user',
      displayName: 'Portal Employee',
      email: 'employee@example.invalid',
    );

    _currentUser = user;

    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(operationDelay);

    _currentUser = null;
  }
}
