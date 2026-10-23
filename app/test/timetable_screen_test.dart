import 'package:classsync/core/theme/app_theme.dart';
import 'package:classsync/features/timetable/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openTimetable(WidgetTester tester, {required int day}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: TimetableScreen(initialDay: day),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('day view lists only that day’s classes', (tester) async {
    await _openTimetable(tester, day: 1);

    expect(find.text('Calculus'), findsOneWidget);
    expect(find.text('Programming'), findsNothing);
  });

  testWidgets('a day without classes shows the free-day message', (
    tester,
  ) async {
    await _openTimetable(tester, day: 6);

    expect(find.text('Free day'), findsOneWidget);
  });

  testWidgets('week view shows a class on every day it repeats', (
    tester,
  ) async {
    await _openTimetable(tester, day: 1);

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();

    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Calculus'), findsNWidgets(3));
  });
}
