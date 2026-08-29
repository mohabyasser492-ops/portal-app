import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/core/widgets/navigation/portal_navigation_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('PortalNavigationShell', () {
    testWidgets('renders the active child', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('Home content'),
          ),
        ),
      );

      expect(find.text('Home content'), findsOneWidget);

      expect(find.byType(PortalNavigationShell), findsOneWidget);
    });

    testWidgets('renders the application bar by default', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('Home content'),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);

      expect(find.text('Portal App'), findsOneWidget);
    });

    testWidgets('can hide the application bar', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            showAppBar: false,
            child: Text('Home content'),
          ),
        ),
      );

      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('uses bottom navigation on a compact viewport', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('Home content'),
          ),
          size: const Size(390, 844),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);

      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('uses a navigation rail on a wide viewport', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('Home content'),
          ),
          size: const Size(1024, 768),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);

      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('uses bottom navigation below the breakpoint', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('Home content'),
          ),
          size: const Size(portalNavigationRailBreakpoint - 1, 800),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);

      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('uses navigation rail at the breakpoint', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('Home content'),
          ),
          size: const Size(portalNavigationRailBreakpoint, 800),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);

      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('renders all compact navigation destinations', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('Home content'),
          ),
          size: const Size(390, 844),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders all wide navigation destinations', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('Home content'),
          ),
          size: const Size(1024, 768),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('selects a compact destination', (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        _buildTestApp(
          PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: (index) {
              selectedIndex = index;
            },
            child: const Text('Home content'),
          ),
          size: const Size(390, 844),
        ),
      );

      await tester.tap(find.text('Services'));

      await tester.pump();

      expect(selectedIndex, PortalNavigationDestination.services.index);
    });

    testWidgets('selects a wide destination', (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        _buildTestApp(
          PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: (index) {
              selectedIndex = index;
            },
            child: const Text('Home content'),
          ),
          size: const Size(1024, 768),
        ),
      );

      await tester.tap(find.text('Requests'));

      await tester.pump();

      expect(selectedIndex, PortalNavigationDestination.requests.index);
    });

    testWidgets('does not select the active destination again', (tester) async {
      var selectionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalNavigationShell(
            currentIndex: PortalNavigationDestination.home.index,
            onDestinationSelected: (index) {
              selectionCount++;
            },
            child: const Text('Home content'),
          ),
          size: const Size(390, 844),
        ),
      );

      await tester.tap(find.text('Home'));

      await tester.pump();

      expect(selectionCount, 0);
    });

    testWidgets('passes the selected index to NavigationBar', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 2,
            onDestinationSelected: _ignoreSelection,
            child: Text('Requests content'),
          ),
          size: const Size(390, 844),
        ),
      );

      final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));

      expect(navigationBar.selectedIndex, 2);
    });

    testWidgets('passes the selected index to NavigationRail', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 3,
            onDestinationSelected: _ignoreSelection,
            child: Text('Profile content'),
          ),
          size: const Size(1024, 768),
        ),
      );

      final navigationRail = tester.widget<NavigationRail>(find.byType(NavigationRail));

      expect(navigationRail.selectedIndex, 3);
    });

    testWidgets('renders correctly in Arabic RTL on compact screens', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('محتوى الصفحة الرئيسية'),
          ),
          size: const Size(390, 844),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('محتوى الصفحة الرئيسية'), findsOneWidget);

      expect(find.byType(NavigationBar), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders correctly in Arabic RTL on wide screens', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('محتوى الصفحة الرئيسية'),
          ),
          size: const Size(1024, 768),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('محتوى الصفحة الرئيسية'), findsOneWidget);

      expect(find.byType(NavigationRail), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports increased text scaling', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalNavigationShell(
            currentIndex: 0,
            onDestinationSelected: _ignoreSelection,
            child: Text('Home content'),
          ),
          size: const Size(390, 844),
          textScaler: const TextScaler.linear(1.5),
        ),
      );

      expect(find.byType(PortalNavigationShell), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}

void _ignoreSelection(int index) {}

Widget _buildTestApp(
  Widget child, {
  Size size = const Size(390, 844),
  TextDirection textDirection = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    child: MaterialApp(
      theme: PortalTheme.light,
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: textScaler),
        child: Directionality(textDirection: textDirection, child: child),
      ),
    ),
  );
}
