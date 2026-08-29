import 'package:flutter/foundation.dart';

import '../../features/authentication/application/authentication_state.dart';

/// Notifies GoRouter when the Portal App authentication state changes.
///
/// GoRouter uses this object through its `refreshListenable` parameter.
/// Authentication state changes therefore cause the router to reevaluate its
/// current route configuration.
final class AuthenticationRouterRefreshNotifier extends ChangeNotifier {
  AuthenticationRouterRefreshNotifier({
    required AuthenticationState initialState,
  }) : _authenticationState = initialState;

  AuthenticationState _authenticationState;

  /// Current authentication state observed by the router.
  AuthenticationState get authenticationState {
    return _authenticationState;
  }

  /// Updates the observed state and notifies GoRouter when it changes.
  void update(AuthenticationState nextState) {
    if (_authenticationState == nextState) {
      return;
    }

    _authenticationState = nextState;
    notifyListeners();
  }
}
