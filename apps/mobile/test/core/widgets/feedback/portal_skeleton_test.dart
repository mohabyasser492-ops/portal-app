import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_radius.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/feedback/portal_skeleton.dart';

void main() {
  group('PortalSkeleton', () {
    testWidgets('renders with the supplied dimensions', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalSkeleton(width: 160, height: 24, animate: false),
        ),
      );

      expect(find.byType(PortalSkeleton), findsOneWidget);

      final skeleton = tester.widget<PortalSkeleton>(
        find.byType(PortalSkeleton),
      );

      expect(skeleton.width, 160);
      expect(skeleton.height, 24);
    });

    testWidgets('uses a rounded rectangle by default', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalSkeleton(width: 160, height: 24, animate: false),
        ),
      );

      final skeleton = tester.widget<PortalSkeleton>(
        find.byType(PortalSkeleton),
      );

      expect(skeleton.shape, PortalSkeletonShape.roundedRectangle);

      final decoration = _findSkeletonDecoration(tester);

      expect(decoration.shape, BoxShape.rectangle);

      expect(decoration.borderRadius, BorderRadius.circular(PortalRadius.md));
    });

    testWidgets('renders a rectangular skeleton', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalSkeleton(
            width: 160,
            height: 24,
            shape: PortalSkeletonShape.rectangle,
            animate: false,
          ),
        ),
      );

      final decoration = _findSkeletonDecoration(tester);

      expect(decoration.shape, BoxShape.rectangle);

      expect(decoration.borderRadius, BorderRadius.zero);
    });

    testWidgets('renders a circular skeleton', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalSkeleton(
            width: 48,
            height: 48,
            shape: PortalSkeletonShape.circle,
            animate: false,
          ),
        ),
      );

      final decoration = _findSkeletonDecoration(tester);

      expect(decoration.shape, BoxShape.circle);

      expect(decoration.borderRadius, isNull);
    });

    testWidgets('uses a custom border radius', (tester) async {
      const customRadius = BorderRadius.all(Radius.circular(20));

      await tester.pumpWidget(
        _buildTestApp(
          const PortalSkeleton(
            width: 160,
            height: 24,
            borderRadius: customRadius,
            animate: false,
          ),
        ),
      );

      final decoration = _findSkeletonDecoration(tester);

      expect(decoration.borderRadius, customRadius);
    });

    testWidgets('renders static decoration when animation is disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalSkeleton(width: 160, height: 24, animate: false),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(PortalSkeleton),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNothing,
      );

      expect(
        find.descendant(
          of: find.byType(PortalSkeleton),
          matching: find.byType(DecoratedBox),
        ),
        findsOneWidget,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses an animated builder when animation is enabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalSkeleton(width: 160, height: 24)),
      );

      expect(
        find.descendant(
          of: find.byType(PortalSkeleton),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });

    testWidgets('can change from animated to static', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalSkeleton(width: 160, height: 24)),
      );

      expect(find.byType(AnimatedBuilder), findsOneWidget);

      await tester.pumpWidget(
        _buildTestApp(
          const PortalSkeleton(width: 160, height: 24, animate: false),
        ),
      );

      await tester.pump();

      expect(find.byType(AnimatedBuilder), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('is excluded from accessibility semantics', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalSkeleton(width: 160, height: 24, animate: false),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(PortalSkeleton),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });
  });

  group('PortalTextSkeleton', () {
    testWidgets('renders the requested number of lines', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextSkeleton(width: 240, lines: 3, animate: false),
        ),
      );

      expect(find.byType(PortalTextSkeleton), findsOneWidget);

      expect(find.byType(PortalSkeleton), findsNWidgets(3));
    });

    testWidgets('uses the supplied line height', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextSkeleton(
            width: 240,
            lines: 3,
            lineHeight: 18,
            animate: false,
          ),
        ),
      );

      final lines = tester
          .widgetList<PortalSkeleton>(find.byType(PortalSkeleton))
          .toList();

      expect(lines.length, 3);

      for (final line in lines) {
        expect(line.height, 18);
      }
    });

    testWidgets('uses full width for lines before the final line', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextSkeleton(
            width: 200,
            lines: 3,
            lastLineWidthFactor: 0.5,
            animate: false,
          ),
        ),
      );

      final lines = tester
          .widgetList<PortalSkeleton>(find.byType(PortalSkeleton))
          .toList();

      expect(lines[0].width, 200);
      expect(lines[1].width, 200);
      expect(lines[2].width, 100);
    });

    testWidgets('renders one shortened line when lines is one', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextSkeleton(
            width: 200,
            lines: 1,
            lastLineWidthFactor: 0.75,
            animate: false,
          ),
        ),
      );

      final line = tester.widget<PortalSkeleton>(find.byType(PortalSkeleton));

      expect(line.width, 150);
    });

    testWidgets('passes animation preference to every line', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextSkeleton(width: 240, lines: 3, animate: false),
        ),
      );

      final lines = tester.widgetList<PortalSkeleton>(
        find.byType(PortalSkeleton),
      );

      expect(lines.every((line) => line.animate == false), isTrue);
    });

    testWidgets('renders correctly in RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextSkeleton(width: 240, lines: 3, animate: false),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.byType(PortalSkeleton), findsNWidgets(3));

      expect(tester.takeException(), isNull);
    });
  });

  group('PortalListTileSkeleton', () {
    testWidgets('renders a leading placeholder by default', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalListTileSkeleton(animate: false)),
      );

      final skeletons = tester
          .widgetList<PortalSkeleton>(find.byType(PortalSkeleton))
          .toList();

      expect(skeletons.length, 3);

      final circularSkeletons = skeletons.where((skeleton) {
        return skeleton.shape == PortalSkeletonShape.circle;
      });

      expect(circularSkeletons.length, 1);
    });

    testWidgets('hides the leading placeholder when requested', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalListTileSkeleton(showLeading: false, animate: false),
        ),
      );

      final skeletons = tester
          .widgetList<PortalSkeleton>(find.byType(PortalSkeleton))
          .toList();

      expect(skeletons.length, 2);

      expect(
        skeletons.any(
          (skeleton) => skeleton.shape == PortalSkeletonShape.circle,
        ),
        isFalse,
      );
    });

    testWidgets('renders a trailing placeholder when requested', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalListTileSkeleton(showTrailing: true, animate: false),
        ),
      );

      final skeletons = tester
          .widgetList<PortalSkeleton>(find.byType(PortalSkeleton))
          .toList();

      expect(skeletons.length, 4);

      final trailingSkeletons = skeletons.where((skeleton) {
        return skeleton.width == 24 && skeleton.height == 24;
      });

      expect(trailingSkeletons.length, 1);
    });

    testWidgets('renders without leading or trailing placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalListTileSkeleton(
            showLeading: false,
            showTrailing: false,
            animate: false,
          ),
        ),
      );

      expect(find.byType(PortalSkeleton), findsNWidgets(2));

      expect(tester.takeException(), isNull);
    });

    testWidgets('passes animation preference to all placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalListTileSkeleton(showTrailing: true, animate: false),
        ),
      );

      final skeletons = tester.widgetList<PortalSkeleton>(
        find.byType(PortalSkeleton),
      );

      expect(skeletons.every((skeleton) => !skeleton.animate), isTrue);
    });

    testWidgets('uses the supplied row width', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalListTileSkeleton(width: 300, animate: false)),
      );

      final listTile = tester.widget<PortalListTileSkeleton>(
        find.byType(PortalListTileSkeleton),
      );

      expect(listTile.width, 300);
    });

    testWidgets('renders correctly in Arabic RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalListTileSkeleton(showTrailing: true, animate: false),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.byType(PortalListTileSkeleton), findsOneWidget);

      expect(find.byType(PortalSkeleton), findsNWidgets(4));

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders inside a narrow container', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const SizedBox(
            width: 240,
            child: PortalListTileSkeleton(showTrailing: true, animate: false),
          ),
        ),
      );

      expect(find.byType(PortalListTileSkeleton), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}

BoxDecoration _findSkeletonDecoration(WidgetTester tester) {
  final decoratedBoxFinder = find.descendant(
    of: find.byType(PortalSkeleton),
    matching: find.byType(DecoratedBox),
  );

  expect(decoratedBoxFinder, findsOneWidget);

  final decoratedBox = tester.widget<DecoratedBox>(decoratedBoxFinder);

  expect(decoratedBox.decoration, isA<BoxDecoration>());

  return decoratedBox.decoration as BoxDecoration;
}

Widget _buildTestApp(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
}) {
  return MaterialApp(
    theme: PortalTheme.light,
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: Center(child: SizedBox(width: 360, child: child)),
      ),
    ),
  );
}
