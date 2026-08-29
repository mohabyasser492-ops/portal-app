import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/application/authentication_controller.dart';
import '../features/authentication/application/authentication_state.dart';
import '../features/authentication/presentation/authentication_gate.dart';
import 'router/authentication_router_refresh_notifier.dart';
import 'router/portal_router.dart';
import 'theme/portal_design_system.dart';

/// Root application widget for Portal App.
class PortalApp extends ConsumerStatefulWidget {
  const PortalApp({this.router, super.key});

  /// Optional router supplied by tests.
  ///
  /// When omitted, the application creates and owns its router.
  final GoRouter? router;

  @override
  ConsumerState<PortalApp> createState() {
    return _PortalAppState();
  }
}

class _PortalAppState extends ConsumerState<PortalApp> {
  late final GoRouter _router;
  late final bool _ownsRouter;
  late final AuthenticationRouterRefreshNotifier _refreshNotifier;
  late final ProviderSubscription<AuthenticationState> _authenticationSubscription;

  @override
  void initState() {
    super.initState();

    final initialAuthenticationState = ref.read(authenticationControllerProvider);

    _refreshNotifier = AuthenticationRouterRefreshNotifier(
      initialState: initialAuthenticationState,
    );

    _ownsRouter = widget.router == null;

    _router = widget.router ?? createPortalRouter(refreshListenable: _refreshNotifier);

    _authenticationSubscription = ref.listenManual<AuthenticationState>(
      authenticationControllerProvider,
      (previousState, nextState) {
        _refreshNotifier.update(nextState);
      },
    );
  }

  @override
  void dispose() {
    _authenticationSubscription.close();

    if (_ownsRouter) {
      _router.dispose();
    }

    _refreshNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Portal App',
      debugShowCheckedModeBanner: false,
      theme: PortalTheme.light,
      routerConfig: _router,
      builder: (context, routerChild) {
        return AuthenticationGate(authenticatedChild: routerChild ?? const SizedBox.shrink());
      },
    );
  }
}
