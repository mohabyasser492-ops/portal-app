import '../../features/authentication/application/authentication_state.dart';
import '../../features/authentication/domain/authentication_status.dart';
import 'authentication_redirect_store.dart';
import 'portal_route_paths.dart';

/// Determines authentication-related navigation redirects.
///
/// This class contains no Flutter widget or GoRouter dependencies, making its
/// redirect behavior easy to test independently.
///
/// The router will call [redirect] whenever navigation or authentication state
/// changes.
final class AuthenticationRedirectGuard {
  AuthenticationRedirectGuard({
    required AuthenticationRedirectStore redirectStore,
  }) : _redirectStore = redirectStore;

  final AuthenticationRedirectStore _redirectStore;

  /// Returns the destination to which the router should redirect.
  ///
  /// Returning `null` means navigation may continue to [currentLocation].
  String? redirect({
    required AuthenticationState authenticationState,
    required String currentLocation,
  }) {
    final normalizedLocation = _normalizeLocation(currentLocation);

    final isAuthenticationLocation = _isAuthenticationLocation(
      normalizedLocation,
    );

    return switch (authenticationState.status) {
      AuthenticationStatus.initializing => _redirectWhileInitializing(
        normalizedLocation,
      ),
      AuthenticationStatus.signedOut => _redirectWhileSignedOut(
        normalizedLocation,
        isAuthenticationLocation: isAuthenticationLocation,
      ),
      AuthenticationStatus.signingIn => _redirectWhileSigningIn(
        normalizedLocation,
      ),
      AuthenticationStatus.signedIn => _redirectWhileSignedIn(
        isAuthenticationLocation: isAuthenticationLocation,
      ),
      AuthenticationStatus.signingOut => _redirectWhileSigningOut(
        normalizedLocation,
      ),
      AuthenticationStatus.failure => _redirectWhileSignedOut(
        normalizedLocation,
        isAuthenticationLocation: isAuthenticationLocation,
      ),
    };
  }

  String? _redirectWhileInitializing(String currentLocation) {
    if (currentLocation == PortalRoutePaths.authenticationLoading) {
      return null;
    }

    if (!_isAuthenticationLocation(currentLocation)) {
      _redirectStore.remember(currentLocation);
    }

    return PortalRoutePaths.authenticationLoading;
  }

  String? _redirectWhileSignedOut(
    String currentLocation, {
    required bool isAuthenticationLocation,
  }) {
    if (currentLocation == PortalRoutePaths.signIn) {
      return null;
    }

    if (!isAuthenticationLocation) {
      _redirectStore.remember(currentLocation);
    }

    return PortalRoutePaths.signIn;
  }

  String? _redirectWhileSigningIn(String currentLocation) {
    if (currentLocation == PortalRoutePaths.signIn) {
      return null;
    }

    if (!_isAuthenticationLocation(currentLocation)) {
      _redirectStore.remember(currentLocation);
    }

    return PortalRoutePaths.signIn;
  }

  String? _redirectWhileSignedIn({required bool isAuthenticationLocation}) {
    if (!isAuthenticationLocation) {
      return null;
    }

    return _redirectStore.consume();
  }

  String? _redirectWhileSigningOut(String currentLocation) {
    if (currentLocation == PortalRoutePaths.authenticationLoading) {
      return null;
    }

    return PortalRoutePaths.authenticationLoading;
  }

  bool _isAuthenticationLocation(String location) {
    return location == PortalRoutePaths.signIn ||
        location == PortalRoutePaths.authenticationLoading;
  }

  String _normalizeLocation(String location) {
    final normalizedLocation = location.trim();

    if (normalizedLocation.isEmpty) {
      return PortalRoutePaths.home;
    }

    return normalizedLocation;
  }
}
