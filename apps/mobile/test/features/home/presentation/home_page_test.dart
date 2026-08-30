import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/features/home/application/home_providers.dart';
import 'package:portal_app/features/home/data/fake_home_repository.dart';
import 'package:portal_app/features/home/domain/home_dashboard.dart';
import 'package:portal_app/features/home/domain/home_repository.dart';
import 'package:portal_app/features/home/presentation/home_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('displays loading while dashboard is requested', (
      tester,
    ) async {
      final dashboardCompleter = Completer<HomeDashboard>();

      final repository = _ControlledHomeRepository(
        loadCallback: () {
          return dashboardCompleter.future;
        },
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);

      expect(
        find.byKey(const ValueKey<String>('home-loading')),
        findsOneWidget,
      );

      expect(repository.loadDashboardCallCount, 1);

      dashboardCompleter.complete(_createPopulatedDashboard());

      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('home-dashboard')),
        findsOneWidget,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays the populated dashboard', (tester) async {
      final repository = FakeHomeRepository(operationDelay: Duration.zero);

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      expect(
        find.byKey(const ValueKey<String>('home-dashboard')),
        findsOneWidget,
      );

      expect(find.text('Welcome, Portal Employee'), findsOneWidget);

      expect(
        find.text('Here is an overview of your Portal activity.'),
        findsOneWidget,
      );

      expect(find.text('Pending requests'), findsOneWidget);

      expect(find.text('Approved requests'), findsOneWidget);

      expect(find.text('Available services'), findsOneWidget);

      expect(find.text('2'), findsOneWidget);

      expect(find.text('5'), findsOneWidget);

      expect(find.text('8'), findsOneWidget);

      expect(repository.loadDashboardCallCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays an empty dashboard state', (tester) async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.empty,
        operationDelay: Duration.zero,
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('home-empty')), findsOneWidget);

      expect(find.text('No dashboard information'), findsOneWidget);

      expect(
        find.text(
          'Dashboard information will appear when it becomes available.',
        ),
        findsOneWidget,
      );

      expect(find.text('Refresh'), findsOneWidget);

      expect(repository.loadDashboardCallCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays a dashboard failure', (tester) async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.failure,
        operationDelay: Duration.zero,
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('home-failure')),
        findsOneWidget,
      );

      expect(find.text('Unable to load dashboard'), findsOneWidget);

      expect(
        find.text('Unable to load the dashboard. Please try again.'),
        findsOneWidget,
      );

      expect(find.text('Try again'), findsOneWidget);

      expect(repository.loadDashboardCallCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('retries after a dashboard failure', (tester) async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.failure,
        operationDelay: Duration.zero,
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('home-failure')),
        findsOneWidget,
      );

      repository.scenario = FakeHomeScenario.populated;

      await tester.tap(find.text('Try again'));

      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('home-dashboard')),
        findsOneWidget,
      );

      expect(find.text('Welcome, Portal Employee'), findsOneWidget);

      expect(repository.loadDashboardCallCount, 2);

      expect(tester.takeException(), isNull);
    });

    testWidgets('refreshes after an empty dashboard result', (tester) async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.empty,
        operationDelay: Duration.zero,
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('home-empty')), findsOneWidget);

      repository.scenario = FakeHomeScenario.populated;

      await tester.tap(find.text('Refresh'));

      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('home-dashboard')),
        findsOneWidget,
      );

      expect(repository.loadDashboardCallCount, 2);

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports pull-to-refresh', (tester) async {
      final repository = FakeHomeRepository(operationDelay: Duration.zero);

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(repository.loadDashboardCallCount, 1);

      await tester.fling(
        find.byKey(const ValueKey<String>('home-dashboard')),
        const Offset(0, 400),
        1000,
      );

      await tester.pump();

      await tester.pump(const Duration(seconds: 1));

      expect(repository.loadDashboardCallCount, 2);

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports increased text scaling', (tester) async {
      final repository = FakeHomeRepository(operationDelay: Duration.zero);

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          textScaler: const TextScaler.linear(2),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      expect(find.text('Welcome, Portal Employee'), findsOneWidget);

      expect(find.text('Pending requests'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Approved requests'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Approved requests'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Available services'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Available services'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Recent requests'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Recent requests'), findsOneWidget);

      expect(repository.loadDashboardCallCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders correctly in RTL', (tester) async {
      final repository = FakeHomeRepository(operationDelay: Duration.zero);

      await tester.pumpWidget(
        _buildTestApp(repository: repository, textDirection: TextDirection.rtl),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      expect(
        find.byKey(const ValueKey<String>('home-dashboard')),
        findsOneWidget,
      );

      expect(find.text('Welcome, Portal Employee'), findsOneWidget);

      final directionalityFinder = find.ancestor(
        of: find.byType(HomePage),
        matching: find.byType(Directionality),
      );

      expect(directionalityFinder, findsWidgets);

      expect(tester.takeException(), isNull);
    });

    testWidgets('loads the dashboard only once after mounting', (tester) async {
      final repository = FakeHomeRepository(operationDelay: Duration.zero);

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(repository.loadDashboardCallCount, 1);

      await tester.pump();

      await tester.pump(const Duration(milliseconds: 100));

      expect(repository.loadDashboardCallCount, 1);

      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildTestApp({
  required HomeRepository repository,
  TextDirection textDirection = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [homeRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: PortalTheme.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          textScaler: textScaler,
        ),
        child: Directionality(
          textDirection: textDirection,
          child: const Scaffold(body: HomePage()),
        ),
      ),
    ),
  );
}

HomeDashboard _createPopulatedDashboard() {
  return HomeDashboard(
    employeeDisplayName: 'Portal Employee',
    pendingRequestCount: 2,
    approvedRequestCount: 5,
    availableServiceCount: 8,
    recentRequests: const [],
    announcements: const [],
  );
}

final class _ControlledHomeRepository implements HomeRepository {
  _ControlledHomeRepository({required this.loadCallback});

  final Future<HomeDashboard> Function() loadCallback;

  int loadDashboardCallCount = 0;

  @override
  Future<HomeDashboard> loadDashboard() {
    loadDashboardCallCount++;

    return loadCallback();
  }
}
