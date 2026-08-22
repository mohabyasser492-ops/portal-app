import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/main.dart';

void main() {
  testWidgets(
    'Portal App displays the Arabic employee portal title',
    (WidgetTester tester) async {
      await tester.pumpWidget(const PortalApp());

      expect(find.text('بوابة الموظفين'), findsOneWidget);
    },
  );
}
