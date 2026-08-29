import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/application/authentication_controller.dart';
import '../features/authentication/application/authentication_state.dart';
import 'router/authentication_redirect_store.dart';
import 'router/authentication_router_refresh_notifier.dart';
import 'router/portal_router.dart';
import 'theme/portal_design_system.dart';

/// Root application widget for Portal App.
class PortalApp extends ConsumerStatefulWidget {
  const PortalApp({this.router, this.initialLocation, super.key});

  /// Optional router supplied by tests.
  ///
  /// When omitted, Portal App creates and owns its standard router.
  final GoRouter? router;

  /// Optional initial location used when Portal App creates the router.
  final String? initialLocation;

  @override
  ConsumerState<PortalApp> createState() {
    return _PortalAppState();
  }
}

class _PortalAppState extends ConsumerState<PortalApp> {
  late final GoRouter _router;
  late final bool _ownsRouter;

  late final AuthenticationRouterRefreshNotifier _authenticationRefreshNotifier;

  late final AuthenticationRedirectStore _redirectStore;

  late final ProviderSubscription<AuthenticationState>
  _authenticationSubscription;

  @override
  void initState() {
    super.initState();

    final initialAuthenticationState = ref.read(
      authenticationControllerProvider,
    );

    _authenticationRefreshNotifier = AuthenticationRouterRefreshNotifier(
      initialState: initialAuthenticationState,
    );

    _redirectStore = AuthenticationRedirectStore();

    _ownsRouter = widget.router == null;

    _router =
        widget.router ??
        createPortalRouter(
          initialLocation: widget.initialLocation ?? '/',
          refreshNotifier: _authenticationRefreshNotifier,
          redirectStore: _redirectStore,
        );

    _authenticationSubscription = ref.listenManual<AuthenticationState>(
      authenticationControllerProvider,
      (previousState, nextState) {
        _authenticationRefreshNotifier.update(nextState);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _initializeAuthentication();
    });
  }

  Future<void> _initializeAuthentication() async {
    await ref.read(authenticationControllerProvider.notifier).initialize();
  }

  @override
  void dispose() {
    _authenticationSubscription.close();

    if (_ownsRouter) {
      _router.dispose();
    }

    _authenticationRefreshNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Portal App',
      debugShowCheckedModeBanner: false,
      theme: PortalTheme.light,
      routerConfig: _router,
    );
  }
}
