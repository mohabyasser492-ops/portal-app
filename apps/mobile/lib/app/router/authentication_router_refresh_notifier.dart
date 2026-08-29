import 'package:flutter/foundation.dart';

import '../../features/authentication/application/authentication_state.dart';

/// Notifies GoRouter when the authentication state changes.
///
/// GoRouter listens to this object through its `refreshListenable` parameter.
/// When authentication changes, the router reevaluates its redirect rules.
final class AuthenticationRouterRefreshNotifier extends ChangeNotifier {
  AuthenticationRouterRefreshNotifier({
    required AuthenticationState initialState,
  }) : _authenticationState = initialState;

  AuthenticationState _authenticationState;

  /// Current authentication state used by router redirect rules.
  AuthenticationState get authenticationState {
    return _authenticationState;
  }

  /// Updates the authentication state and refreshes the router when needed.
  ///
  /// No notification is sent when the new state equals the current state.
  void update(AuthenticationState nextState) {
    if (_authenticationState == nextState) {
      return;
    }

    _authenticationState = nextState;
    notifyListeners();
  }
}
