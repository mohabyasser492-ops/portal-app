import 'portal_route_paths.dart';

/// Stores the application route requested before authentication.
///
/// After authentication succeeds, [consume] returns the stored location and
/// clears it. If no location was stored, [consume] returns the configured
/// default location.
///
/// This class stores route information only. It must never store credentials,
/// authentication tokens, or user information.
final class AuthenticationRedirectStore {
  AuthenticationRedirectStore({String defaultLocation = PortalRoutePaths.home})
    : _defaultLocation = defaultLocation;

  final String _defaultLocation;

  String? _intendedLocation;

  /// The protected route requested before authentication.
  String? get intendedLocation {
    return _intendedLocation;
  }

  /// Whether an intended location is currently stored.
  bool get hasIntendedLocation {
    return _intendedLocation != null;
  }

  /// Stores a valid application location for post-sign-in navigation.
  ///
  /// The following values are ignored:
  ///
  /// - Empty locations
  /// - Relative locations
  /// - Protocol-relative locations
  /// - The sign-in route
  /// - The authentication-loading route
  ///
  /// Invalid locations do not remove an existing valid location.
  void remember(String location) {
    final normalizedLocation = location.trim();

    if (!_isValidLocation(normalizedLocation)) {
      return;
    }

    _intendedLocation = normalizedLocation;
  }

  /// Returns and clears the intended location.
  ///
  /// If no intended location is present, the configured default location is
  /// returned.
  String consume() {
    final location = _intendedLocation ?? _defaultLocation;

    _intendedLocation = null;

    return location;
  }

  /// Clears the intended location without returning it.
  void clear() {
    _intendedLocation = null;
  }

  bool _isValidLocation(String location) {
    if (location.isEmpty) {
      return false;
    }

    if (!location.startsWith('/')) {
      return false;
    }

    if (location.startsWith('//')) {
      return false;
    }

    final uri = Uri.tryParse(location);

    if (uri == null) {
      return false;
    }

    if (uri.hasScheme || uri.hasAuthority) {
      return false;
    }

    if (uri.path == PortalRoutePaths.signIn || uri.path == PortalRoutePaths.authenticationLoading) {
      return false;
    }

    return true;
  }
}
