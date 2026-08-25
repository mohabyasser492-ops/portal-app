import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_colors.dart';
import 'package:portal_app/app/theme/portal_spacing.dart';
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

    testWidgets('renders title without subtitle', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            title: 'Employee profile',
            child: Text('Card content'),
          ),
        ),
      );

      expect(find.text('Employee profile'), findsOneWidget);
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders subtitle without title', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            subtitle: 'Personal and employment information',
            child: Text('Card content'),
          ),
        ),
      );

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

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('does not provide a tap action when onTap is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalCard(child: Text('Card content'))),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));

      expect(inkWell.onTap, isNull);
    });

    testWidgets('provides a tap action when interactive', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalCard(onTap: () {}, child: const Text('Interactive card')),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));

      expect(inkWell.onTap, isNotNull);
      expect(inkWell.canRequestFocus, isTrue);
    });

    testWidgets('uses the supplied padding and margin', (tester) async {
      const customPadding = EdgeInsetsDirectional.all(24);
      const customMargin = EdgeInsetsDirectional.all(8);

      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            padding: customPadding,
            margin: customMargin,
            child: Text('Card content'),
          ),
        ),
      );

      final cardContainer = _findCardContainer(tester);

      expect(cardContainer.margin, customMargin);

      final matchingPaddingWidgets = tester
          .widgetList<Padding>(find.byType(Padding))
          .where((paddingWidget) => paddingWidget.padding == customPadding);

      expect(matchingPaddingWidgets, isNotEmpty);
    });

    testWidgets('uses zero margin by default', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalCard(child: Text('Card content'))),
      );

      final cardContainer = _findCardContainer(tester);

      expect(cardContainer.margin, EdgeInsets.zero);
    });

    testWidgets('uses standard internal padding by default', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalCard(child: Text('Card content'))),
      );

      const expectedPadding = EdgeInsetsDirectional.all(PortalSpacing.md);

      final matchingPaddingWidgets = tester
          .widgetList<Padding>(find.byType(Padding))
          .where((paddingWidget) => paddingWidget.padding == expectedPadding);

      expect(matchingPaddingWidgets, isNotEmpty);
    });

    testWidgets('renders the standard variant with a border', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            variant: PortalCardVariant.standard,
            child: Text('Standard content'),
          ),
        ),
      );

      final decoration = _findCardDecoration(tester);

      expect(decoration.color, PortalColors.surfacePrimary);
      expect(decoration.border, isNotNull);
      expect(decoration.boxShadow, isEmpty);
    });

    testWidgets('renders the outlined variant with a border', (tester) async {
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

    testWidgets('renders the elevated variant with a shadow', (tester) async {
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

    testWidgets('renders the interactive variant with a shadow', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalCard(
            variant: PortalCardVariant.interactive,
            onTap: () {},
            child: const Text('Interactive content'),
          ),
        ),
      );

      final decoration = _findCardDecoration(tester);

      expect(decoration.border, isNotNull);
      expect(decoration.boxShadow, isNotEmpty);
    });

    testWidgets('uses a transparent Material surface', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalCard(child: Text('Card content'))),
      );

      final material = tester.widget<Material>(find.byType(Material).last);

      expect(material.color, Colors.transparent);
      expect(material.clipBehavior, Clip.antiAlias);
    });

    testWidgets('exposes an accessible semantic label', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          PortalCard(
            semanticLabel: 'Open employee profile',
            onTap: () {},
            child: const Text('Employee profile'),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Open employee profile'),
        findsAtLeastNWidgets(1),
      );

      semanticsHandle.dispose();
    });

    testWidgets('provides semantics for an interactive card', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          PortalCard(
            semanticLabel: 'Open employee profile',
            onTap: () {},
            child: const Text('Employee profile'),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Open employee profile'),
        findsAtLeastNWidgets(1),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));

      expect(inkWell.onTap, isNotNull);

      semanticsHandle.dispose();
    });

    testWidgets('preserves visible child content by default', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            semanticLabel: 'Employee information card',
            child: Text('Employee profile details'),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Employee information card'),
        findsAtLeastNWidgets(1),
      );
      expect(find.text('Employee profile details'), findsOneWidget);

      semanticsHandle.dispose();
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
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports mixed Arabic and English content', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalCard(
            title: 'الملف الشخصي Profile',
            subtitle: 'الموظف Employee 123',
            child: Text('Portal App بوابة الموظف'),
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('الملف الشخصي Profile'), findsOneWidget);
      expect(find.text('الموظف Employee 123'), findsOneWidget);
      expect(find.text('Portal App بوابة الموظف'), findsOneWidget);
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
              'The information displayed here is provided by the employee system.',
            ),
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(PortalCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders child-only content without a header row', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalCard(child: Text('Only card content'))),
      );

      expect(find.text('Only card content'), findsOneWidget);
      expect(find.byType(Row), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

Container _findCardContainer(WidgetTester tester) {
  final containers = tester.widgetList<Container>(find.byType(Container));

  return containers.firstWhere(
    (container) => container.decoration is BoxDecoration,
  );
}

BoxDecoration _findCardDecoration(WidgetTester tester) {
  final cardContainer = _findCardContainer(tester);
  final decoration = cardContainer.decoration;

  expect(decoration, isA<BoxDecoration>());

  return decoration! as BoxDecoration;
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
