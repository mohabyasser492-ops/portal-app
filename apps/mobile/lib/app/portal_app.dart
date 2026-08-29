import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router/portal_router.dart';
import 'theme/portal_design_system.dart';

/// Root application widget for Portal App.
class PortalApp extends StatefulWidget {
  const PortalApp({this.router, super.key});

  /// Optional router supplied by tests or application hosts.
  ///
  /// When omitted, the application creates its standard production router.
  final GoRouter? router;

  @override
  State<PortalApp> createState() => _PortalAppState();
}

class _PortalAppState extends State<PortalApp> {
  late final GoRouter _router;
  late final bool _ownsRouter;

  @override
  void initState() {
    super.initState();

    _ownsRouter = widget.router == null;
    _router = widget.router ?? createPortalRouter();
  }

  @override
  void dispose() {
    if (_ownsRouter) {
      _router.dispose();
    }

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
