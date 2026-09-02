import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/features/services/presentation/widgets/services_search_field.dart';

void main() {
  group('ServicesSearchField', () {
    testWidgets('displays the search label and hint', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(ServicesSearchField(query: '', onChanged: (_) {})),
      );

      expect(find.byType(ServicesSearchField), findsOneWidget);

      expect(
        find.byKey(const ValueKey<String>('services-search-field')),
        findsOneWidget,
      );

      expect(find.text('Search services'), findsOneWidget);

      expect(find.text('Search by name or description'), findsOneWidget);

      expect(find.byIcon(Icons.search), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays the initial query', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(ServicesSearchField(query: 'payroll', onChanged: (_) {})),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.controller?.text, 'payroll');

      expect(find.text('payroll'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('reports query changes', (tester) async {
      final reportedQueries = <String>[];

      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(query: '', onChanged: reportedQueries.add),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey<String>('services-search-field')),
        'leave',
      );

      await tester.pump();

      expect(reportedQueries, isNotEmpty);

      expect(reportedQueries.last, 'leave');

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.controller?.text, 'leave');

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the clear button when a query exists', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(query: 'documents', onChanged: (_) {}),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('services-search-clear-button')),
        findsOneWidget,
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not show the clear button for an empty query', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(ServicesSearchField(query: '', onChanged: (_) {})),
      );

      expect(
        find.byKey(const ValueKey<String>('services-search-clear-button')),
        findsNothing,
      );

      expect(find.byIcon(Icons.clear), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the clear button after entering text', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(ServicesSearchField(query: '', onChanged: (_) {})),
      );

      expect(find.byIcon(Icons.clear), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey<String>('services-search-field')),
        'profile',
      );

      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('services-search-clear-button')),
        findsOneWidget,
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('clears the query and reports an empty value', (tester) async {
      final reportedQueries = <String>[];

      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(query: 'payroll', onChanged: reportedQueries.add),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('services-search-clear-button')),
      );

      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.controller?.text, isEmpty);

      expect(reportedQueries, isNotEmpty);

      expect(reportedQueries.last, isEmpty);

      expect(
        find.byKey(const ValueKey<String>('services-search-clear-button')),
        findsNothing,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('updates when the external query changes', (tester) async {
      const fieldKey = ValueKey<String>('services-search-widget');

      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(key: fieldKey, query: 'leave', onChanged: (_) {}),
        ),
      );

      var textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.controller?.text, 'leave');

      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(
            key: fieldKey,
            query: 'documents',
            onChanged: (_) {},
          ),
        ),
      );

      await tester.pump();

      textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.controller?.text, 'documents');

      expect(tester.takeException(), isNull);
    });

    testWidgets('clears when the external query is cleared', (tester) async {
      const fieldKey = ValueKey<String>('services-search-widget');

      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(
            key: fieldKey,
            query: 'profile',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(key: fieldKey, query: '', onChanged: (_) {}),
        ),
      );

      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.controller?.text, isEmpty);

      expect(find.byIcon(Icons.clear), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('places the cursor at the end after external update', (
      tester,
    ) async {
      const fieldKey = ValueKey<String>('services-search-widget');

      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(key: fieldKey, query: '', onChanged: (_) {}),
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(
            key: fieldKey,
            query: 'payroll',
            onChanged: (_) {},
          ),
        ),
      );

      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(
        textField.controller?.selection,
        const TextSelection.collapsed(offset: 7),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('disables text input when disabled', (tester) async {
      final reportedQueries = <String>[];

      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(
            query: '',
            enabled: false,
            onChanged: reportedQueries.add,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.enabled, isFalse);

      await tester.enterText(find.byType(TextField), 'leave');

      await tester.pump();

      expect(reportedQueries, isEmpty);

      expect(tester.takeException(), isNull);
    });

    testWidgets('disables the clear action when disabled', (tester) async {
      final reportedQueries = <String>[];

      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(
            query: 'payroll',
            enabled: false,
            onChanged: reportedQueries.add,
          ),
        ),
      );

      final clearButtonFinder = find.byKey(
        const ValueKey<String>('services-search-clear-button'),
      );

      expect(clearButtonFinder, findsOneWidget);

      final clearButton = tester.widget<IconButton>(clearButtonFinder);

      expect(clearButton.onPressed, isNull);

      expect(reportedQueries, isEmpty);

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the search text input action', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(ServicesSearchField(query: '', onChanged: (_) {})),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.textInputAction, TextInputAction.search);

      expect(tester.takeException(), isNull);
    });

    testWidgets('provides search accessibility semantics', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(ServicesSearchField(query: '', onChanged: (_) {})),
      );

      expect(find.bySemanticsLabel('Search services'), findsWidgets);

      expect(tester.takeException(), isNull);

      semanticsHandle.dispose();
    });

    testWidgets('provides a tooltip for the clear button', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(ServicesSearchField(query: 'leave', onChanged: (_) {})),
      );

      final clearButtonFinder = find.byKey(
        const ValueKey<String>('services-search-clear-button'),
      );

      expect(clearButtonFinder, findsOneWidget);

      final clearButton = tester.widget<IconButton>(clearButtonFinder);

      expect(clearButton.tooltip, 'Clear service search');

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports increased text scaling', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(
            query: 'synthetic long service search query',
            onChanged: (_) {},
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(ServicesSearchField), findsOneWidget);

      expect(find.text('Search services'), findsOneWidget);

      expect(find.text('synthetic long service search query'), findsOneWidget);

      expect(find.byIcon(Icons.clear), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses directional layout in RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          ServicesSearchField(query: 'خدمة', onChanged: (_) {}),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.byType(ServicesSearchField), findsOneWidget);

      expect(find.text('خدمة'), findsOneWidget);

      expect(find.byIcon(Icons.search), findsOneWidget);

      expect(find.byIcon(Icons.clear), findsOneWidget);

      final directionalityFinder = find.ancestor(
        of: find.byType(ServicesSearchField),
        matching: find.byType(Directionality),
      );

      expect(directionalityFinder, findsWidgets);

      final directionality = tester.widget<Directionality>(
        directionalityFinder.first,
      );

      expect(directionality.textDirection, TextDirection.rtl);

      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildTestApp(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    theme: PortalTheme.light,
    home: MediaQuery(
      data: MediaQueryData(size: const Size(390, 844), textScaler: textScaler),
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}
