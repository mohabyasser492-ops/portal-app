import 'package:flutter/foundation.dart';

import '../../features/authentication/application/authentication_state.dart';

/// Notifies GoRouter when authentication state changes.
final class AuthenticationRouterRefreshNotifier extends ChangeNotifier {
  AuthenticationRouterRefreshNotifier({
    required AuthenticationState initialState,
  }) : _authenticationState = initialState;

  AuthenticationState _authenticationState;

  /// Current authentication state observed by GoRouter.
  AuthenticationState get authenticationState {
    return _authenticationState;
  }

  /// Updates the state and triggers router redirect evaluation.
  void update(AuthenticationState nextState) {
    if (_authenticationState == nextState) {
      return;
    }

    _authenticationState = nextState;
    notifyListeners();
  }
}
