import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/inputs/portal_text_field.dart';

void main() {
  group('PortalTextField', () {
    testWidgets('renders its label and hint', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'Employee name',
            hint: 'Enter employee name',
          ),
        ),
      );

      expect(find.text('Employee name'), findsOneWidget);
      expect(find.text('Enter employee name'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalTextField(label: 'Employee name')),
      );

      await tester.enterText(find.byType(TextFormField), 'Portal Employee');

      await tester.pump();

      expect(find.text('Portal Employee'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        _buildTestApp(
          PortalTextField(
            label: 'Employee name',
            onChanged: (value) {
              changedValue = value;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Portal Employee');

      await tester.pump();

      expect(changedValue, 'Portal Employee');
    });

    testWidgets('calls onSubmitted when the field is submitted', (
      tester,
    ) async {
      String? submittedValue;

      await tester.pumpWidget(
        _buildTestApp(
          PortalTextField(
            label: 'Employee name',
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              submittedValue = value;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Portal Employee');

      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pump();

      expect(submittedValue, 'Portal Employee');
    });

    testWidgets('displays externally supplied error text', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'Employee name',
            errorText: 'Employee name is required',
          ),
        ),
      );

      expect(find.text('Employee name is required'), findsOneWidget);
    });

    testWidgets('displays helper text', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'Employee name',
            helperText: 'Use the name shown in the employee record.',
          ),
        ),
      );

      expect(
        find.text('Use the name shown in the employee record.'),
        findsOneWidget,
      );
    });

    testWidgets('displays a validator error in a form', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _buildTestApp(
          Form(
            key: formKey,
            child: PortalTextField(
              label: 'Employee name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Employee name is required';
                }

                return null;
              },
            ),
          ),
        ),
      );

      final isValid = formKey.currentState!.validate();

      await tester.pump();

      expect(isValid, isFalse);
      expect(find.text('Employee name is required'), findsOneWidget);
    });

    testWidgets('accepts a valid value in a form', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _buildTestApp(
          Form(
            key: formKey,
            child: PortalTextField(
              label: 'Employee name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Employee name is required';
                }

                return null;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Portal Employee');

      final isValid = formKey.currentState!.validate();

      await tester.pump();

      expect(isValid, isTrue);
      expect(find.text('Employee name is required'), findsNothing);
    });

    testWidgets('renders a leading icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(label: 'Search', leadingIcon: Icons.search),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders a non-interactive trailing icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(label: 'Search', trailingIcon: Icons.close),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('calls the trailing icon action', (tester) async {
      var actionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalTextField(
            label: 'Search',
            trailingIcon: Icons.close,
            onTrailingIconPressed: () {
              actionCount++;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(actionCount, 1);
    });

    testWidgets('does not accept input while disabled', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'Employee number',
            enabled: false,
            initialValue: '12345',
          ),
        ),
      );

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );

      expect(editableText.readOnly, isTrue);
      expect(find.text('12345'), findsOneWidget);
    });

    testWidgets('disables an interactive trailing icon with the field', (
      tester,
    ) async {
      var actionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalTextField(
            label: 'Search',
            enabled: false,
            trailingIcon: Icons.close,
            onTrailingIconPressed: () {
              actionCount++;
            },
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));

      expect(iconButton.onPressed, isNull);
      expect(actionCount, 0);
    });

    testWidgets('supports read-only values', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'Employee number',
            readOnly: true,
            initialValue: '12345',
          ),
        ),
      );

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );

      expect(editableText.readOnly, isTrue);
      expect(find.text('12345'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'Password',
            obscureText: true,
            showPasswordToggle: true,
          ),
        ),
      );

      EditableText editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );

      expect(editableText.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));

      await tester.pump();

      editableText = tester.widget<EditableText>(find.byType(EditableText));

      expect(editableText.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('disables the password toggle in read-only mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'Password',
            obscureText: true,
            showPasswordToggle: true,
            readOnly: true,
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));

      expect(iconButton.onPressed, isNull);
    });

    testWidgets('forces password fields to use one line', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'Password',
            obscureText: true,
            maxLines: 4,
          ),
        ),
      );

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );

      expect(editableText.obscureText, isTrue);
      expect(editableText.maxLines, 1);
    });

    testWidgets('supports multiline input', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(label: 'Description', minLines: 3, maxLines: 5),
        ),
      );

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );

      expect(editableText.minLines, 3);
      expect(editableText.maxLines, 5);
    });

    testWidgets('supports a character limit', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(label: 'Description', maxLength: 10),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '123456789012345');

      await tester.pump();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );

      expect(editableText.controller.text.length, 10);
      expect(editableText.controller.text, '1234567890');
    });

    testWidgets('renders a required-field indicator', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(label: 'Employee name', requiredField: true),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);

      expect(find.textContaining('*', findRichText: true), findsOneWidget);
    });

    testWidgets('exposes the custom semantic label', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'Employee name',
            semanticLabel: 'Enter the employee full name',
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Enter the employee full name'),
        findsAtLeastNWidgets(1),
      );

      semantics.dispose();
    });

    testWidgets('renders correctly in Arabic RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'اسم الموظف',
            hint: 'أدخل اسم الموظف',
            helperText: 'استخدم الاسم المسجل في ملف الموظف',
            leadingIcon: Icons.person_outline,
            requiredField: true,
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('اسم الموظف'), findsOneWidget);
      expect(find.text('أدخل اسم الموظف'), findsOneWidget);
      expect(find.text('استخدم الاسم المسجل في ملف الموظف'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports mixed Arabic and English input', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(label: 'اسم الموظف'),
          textDirection: TextDirection.rtl,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Fares 123 فارس');

      await tester.pump();

      expect(find.text('Fares 123 فارس'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow with increased text scaling', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalTextField(
            label: 'Employee full name',
            hint: 'Enter the employee full name',
            helperText: 'Use the name displayed on the employee record.',
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );
}
