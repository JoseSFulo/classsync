import 'package:classsync/core/theme/app_theme.dart';
import 'package:classsync/features/timetable/class_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _open(WidgetTester tester, {String? classId}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: ClassFormScreen(classId: classId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a new class cannot be saved without a name', (tester) async {
    await _open(tester);

    expect(find.text('New class'), findsOneWidget);
    await tester.ensureVisible(find.text('Save class'));
    await tester.tap(find.text('Save class'));
    await tester.pumpAndSettle();

    expect(find.text('Add a class name.'), findsOneWidget);
  });

  testWidgets('editing shows the saved class and a delete button', (
    tester,
  ) async {
    await _open(tester, classId: 'class-1');

    expect(find.text('Edit class'), findsOneWidget);
    expect(find.text('Calculus'), findsOneWidget);
    expect(find.text('Delete class'), findsOneWidget);
  });
}
