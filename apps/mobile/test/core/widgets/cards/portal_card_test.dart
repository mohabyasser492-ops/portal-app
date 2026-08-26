import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/cards/portal_card.dart';

void main() {
  group('PortalCard', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalCard(child: Text('Card content'))),
      );

      expect(find.byType(PortalCard), findsOneWidget);
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            title: 'Employee profile',
            subtitle: 'Personal and employment information',
            child: Text('Card content'),
          ),
        ),
      );

      expect(find.text('Employee profile'), findsOneWidget);
      expect(find.text('Personal and employment information'), findsOneWidget);
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders leading and trailing widgets', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            title: 'Employee profile',
            leading: Icon(Icons.person_outline),
            trailing: Icon(Icons.chevron_right),
            child: Text('Card content'),
          ),
        ),
      );

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('calls onTap when selected', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalCard(
            title: 'Employee profile',
            onTap: () {
              tapCount++;
            },
            child: const Text('Card content'),
          ),
        ),
      );

      await tester.tap(
        find.descendant(
          of: find.byType(PortalCard),
          matching: find.byType(InkWell),
        ),
      );
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('does not provide a tap action when onTap is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalCard(child: Text('Card content'))),
      );

      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(PortalCard),
          matching: find.byType(InkWell),
        ),
      );

      expect(inkWell.onTap, isNull);
    });

    testWidgets('renders the elevated variant', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            variant: PortalCardVariant.elevated,
            child: Text('Elevated content'),
          ),
        ),
      );

      final decoration = _findCardDecoration(tester);

      expect(decoration.border, isNull);
      expect(decoration.boxShadow, isNotEmpty);
    });

    testWidgets('renders the outlined variant', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            variant: PortalCardVariant.outlined,
            child: Text('Outlined content'),
          ),
        ),
      );

      final decoration = _findCardDecoration(tester);

      expect(decoration.border, isNotNull);
      expect(decoration.boxShadow, isEmpty);
    });

    testWidgets('exposes an accessible semantic label', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalCard(
            semanticLabel: 'Open employee profile',
            onTap: () {},
            child: const Text('Employee profile'),
          ),
        ),
      );

      final semanticsWidget = _findSemanticsWithLabel(
        tester,
        'Open employee profile',
      );

      expect(semanticsWidget.properties.label, 'Open employee profile');
      expect(semanticsWidget.properties.button, isTrue);
    });

    testWidgets('provides semantics for an interactive card', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalCard(
            semanticLabel: 'Open employee profile',
            onTap: () {},
            child: const Text('Employee profile'),
          ),
        ),
      );

      final semanticsWidget = _findSemanticsWithLabel(
        tester,
        'Open employee profile',
      );

      expect(semanticsWidget.properties.button, isTrue);
      expect(semanticsWidget.properties.enabled, isTrue);

      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(PortalCard),
          matching: find.byType(InkWell),
        ),
      );

      expect(inkWell.onTap, isNotNull);
    });

    testWidgets('preserves visible child content by default', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            semanticLabel: 'Employee information card',
            child: Text('Employee profile details'),
          ),
        ),
      );

      expect(find.text('Employee profile details'), findsOneWidget);

      final semanticsWidget = _findSemanticsWithLabel(
        tester,
        'Employee information card',
      );

      expect(semanticsWidget.properties.label, 'Employee information card');
    });

    testWidgets('renders correctly in Arabic RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            title: 'الملف الشخصي',
            subtitle: 'المعلومات الشخصية والوظيفية',
            leading: Icon(Icons.person_outline),
            trailing: Icon(Icons.chevron_left),
            child: Text('بيانات الموظف'),
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('الملف الشخصي'), findsOneWidget);
      expect(find.text('المعلومات الشخصية والوظيفية'), findsOneWidget);
      expect(find.text('بيانات الموظف'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow with increased text scaling', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            title: 'Employee profile and employment information',
            subtitle:
                'Review personal, departmental, contact, and shift details.',
            leading: Icon(Icons.person_outline),
            child: Text(
              'The information displayed here is synthetic preview content.',
            ),
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(PortalCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Semantics _findSemanticsWithLabel(WidgetTester tester, String label) {
  final finder = find.byWidgetPredicate((widget) {
    return widget is Semantics && widget.properties.label == label;
  });

  expect(finder, findsOneWidget);

  return tester.widget<Semantics>(finder);
}

BoxDecoration _findCardDecoration(WidgetTester tester) {
  final containers = tester.widgetList<Container>(
    find.descendant(
      of: find.byType(PortalCard),
      matching: find.byType(Container),
    ),
  );

  final container = containers.firstWhere(
    (candidate) => candidate.decoration is BoxDecoration,
  );

  return container.decoration! as BoxDecoration;
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );
}
