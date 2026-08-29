import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_app/app/portal_app.dart';
import 'package:portal_app/app/router/portal_route_paths.dart';
import 'package:portal_app/app/router/portal_router.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/core/widgets/navigation/portal_navigation_shell.dart';
import 'package:portal_app/features/home/presentation/home_placeholder_page.dart';
import 'package:portal_app/features/not_found/presentation/not_found_page.dart';
import 'package:portal_app/features/profile/presentation/profile_placeholder_page.dart';
import 'package:portal_app/features/requests/presentation/requests_placeholder_page.dart';
import 'package:portal_app/features/services/presentation/services_placeholder_page.dart';

void main() {
  group('PortalApp', () {
    testWidgets('uses the Portal application theme', (tester) async {
      final router = createPortalRouter();

      await tester.pumpWidget(PortalApp(router: router));

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(materialApp.theme?.colorScheme.primary, PortalColors.actionPrimary);

      expect(materialApp.theme?.scaffoldBackgroundColor, PortalColors.surfaceSecondary);

      expect(materialApp.debugShowCheckedModeBanner, isFalse);

      await _disposeRouter(tester, router);
    });

    testWidgets('starts on the Home destination', (tester) async {
      final router = createPortalRouter();

      await tester.pumpWidget(PortalApp(router: router));

      await tester.pumpAndSettle();

      expect(find.byType(HomePlaceholderPage), findsOneWidget);

      expect(find.byType(PortalNavigationShell), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.home);

      await _disposeRouter(tester, router);
    });

    testWidgets('navigates between all primary destinations', (tester) async {
      final router = createPortalRouter();

      await tester.pumpWidget(PortalApp(router: router));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Services'));

      await tester.pumpAndSettle();

      expect(find.byType(ServicesPlaceholderPage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.services);

      await tester.tap(find.text('Requests'));

      await tester.pumpAndSettle();

      expect(find.byType(RequestsPlaceholderPage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.requests);

      await tester.tap(find.text('Profile'));

      await tester.pumpAndSettle();

      expect(find.byType(ProfilePlaceholderPage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.profile);

      await tester.tap(find.text('Home'));

      await tester.pumpAndSettle();

      expect(find.byType(HomePlaceholderPage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.home);

      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('opens the design-system preview', (tester) async {
      final router = createPortalRouter();

      await tester.pumpWidget(PortalApp(router: router));

      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open design system'));

      await tester.pumpAndSettle();

      expect(find.text('Portal App components'), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.designSystem);

      await _disposeRouter(tester, router);
    });

    testWidgets('returns to the active branch from the preview', (tester) async {
      final router = createPortalRouter(initialLocation: PortalRoutePaths.services);

      await tester.pumpWidget(PortalApp(router: router));

      await tester.pumpAndSettle();

      expect(find.byType(ServicesPlaceholderPage), findsOneWidget);

      await tester.tap(find.byTooltip('Open design system'));

      await tester.pumpAndSettle();

      expect(find.text('Portal App components'), findsOneWidget);

      router.pop();

      await tester.pumpAndSettle();

      expect(find.byType(ServicesPlaceholderPage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.services);

      await _disposeRouter(tester, router);
    });

    testWidgets('shows a safe fallback for an unknown route', (tester) async {
      final router = createPortalRouter(initialLocation: '/unknown-route');

      await tester.pumpWidget(PortalApp(router: router));

      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPage), findsOneWidget);

      expect(find.text('Page not found'), findsWidgets);

      expect(find.textContaining('/unknown-route'), findsOneWidget);

      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('returns home from the unknown-route page', (tester) async {
      final router = createPortalRouter(initialLocation: '/unknown-route');

      await tester.pumpWidget(PortalApp(router: router));

      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPage), findsOneWidget);

      await tester.tap(find.text('Return home'));

      await tester.pumpAndSettle();

      expect(find.byType(HomePlaceholderPage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.home);

      await _disposeRouter(tester, router);
    });

    testWidgets('uses bottom navigation on a compact screen', (tester) async {
      final router = createPortalRouter();

      await _setTestViewport(tester, const Size(390, 844));

      await tester.pumpWidget(PortalApp(router: router));

      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);

      expect(find.byType(NavigationRail), findsNothing);

      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('uses a navigation rail on a wide screen', (tester) async {
      final router = createPortalRouter();

      await _setTestViewport(tester, const Size(1024, 768));

      await tester.pumpWidget(PortalApp(router: router));

      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);

      expect(find.byType(NavigationBar), findsNothing);

      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });
  });
}

Future<void> _setTestViewport(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;

  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  await tester.pump();
}

Future<void> _disposeRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(const SizedBox.shrink());

  await tester.pump();

  router.dispose();
}
