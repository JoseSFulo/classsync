import 'package:classsync/core/theme/app_theme.dart';
import 'package:classsync/features/reminders/reminder_providers.dart';
import 'package:classsync/features/timetable/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_reminder_scheduler.dart';

Future<void> _open(WidgetTester tester, FakeReminderScheduler scheduler) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [reminderSchedulerProvider.overrideWithValue(scheduler)],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const TimetableScreen(initialDay: 1),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('explains first, then asks the system for permission', (
    tester,
  ) async {
    final scheduler = FakeReminderScheduler(allowed: false);
    await _open(tester, scheduler);

    expect(find.text('Allow reminders?'), findsOneWidget);
    expect(scheduler.requestCount, 0);

    await tester.tap(find.text('Allow reminders'));
    await tester.pumpAndSettle();

    expect(scheduler.requestCount, 1);
  });

  testWidgets('Not now does not ask the system', (tester) async {
    final scheduler = FakeReminderScheduler(allowed: false);
    await _open(tester, scheduler);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(scheduler.requestCount, 0);
  });

  testWidgets('no dialog when reminders are already allowed', (tester) async {
    await _open(tester, FakeReminderScheduler());

    expect(find.text('Allow reminders?'), findsNothing);
  });
}
