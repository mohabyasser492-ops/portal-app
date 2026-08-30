import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/core/widgets/feedback/portal_error_state.dart';
import 'package:portal_app/core/widgets/feedback/portal_skeleton.dart';
import 'package:portal_app/features/profile/application/profile_providers.dart';
import 'package:portal_app/features/profile/data/fake_profile_repository.dart';
import 'package:portal_app/features/profile/presentation/profile_page.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('displays loading skeleton initially', (tester) async {
      final repository = FakeProfileRepository(
        operationDelay: const Duration(seconds: 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: PortalTheme.light,
            home: const ProfilePage(),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('profile-loading')), findsOneWidget);
      expect(find.byType(PortalSkeleton), findsWidgets);
      
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('displays profile data successfully', (tester) async {
      final repository = FakeProfileRepository(
        operationDelay: Duration.zero,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: PortalTheme.light,
            home: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('profile-data')), findsOneWidget);
      expect(find.text('Portal Employee'), findsWidgets);
      expect(find.text('Senior Software Engineer'), findsOneWidget);
      expect(find.text('Engineering & Technology'), findsOneWidget);
      expect(find.text('employee@portal.local'), findsOneWidget);
      expect(find.text('+971 50 123 4567'), findsOneWidget);
      expect(find.text('EMP-001024'), findsOneWidget);
      expect(find.text('Sarah Manager'), findsOneWidget);
    });

    testWidgets('displays failure view on error and allows retry', (tester) async {
      final repository = FakeProfileRepository(
        scenario: FakeProfileScenario.failure,
        operationDelay: Duration.zero,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: PortalTheme.light,
            home: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('profile-failure')), findsOneWidget);
      expect(find.byType(PortalErrorState), findsOneWidget);

      repository.scenario = FakeProfileScenario.populated;

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('profile-data')), findsOneWidget);
    });
    
    testWidgets('supports pull-to-refresh', (tester) async {
      final repository = FakeProfileRepository(
        operationDelay: Duration.zero,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: PortalTheme.light,
            home: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      final initialCount = repository.loadProfileCallCount;

      await tester.drag(find.byKey(const ValueKey('profile-data')), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(repository.loadProfileCallCount, initialCount + 1);
    });
  });
}
