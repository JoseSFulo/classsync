import 'package:classsync/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:classsync/features/reminders/reminder_providers.dart';

import 'support/fake_reminder_scheduler.dart';

Future<void> _openApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        reminderSchedulerProvider.overrideWithValue(FakeReminderScheduler()),
      ],
      child: const ClassSyncApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.tap(find.text('Continue with Google'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a signed-out user sees the sign-in screen', (tester) async {
    await _openApp(tester);

    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('signing in opens the timetable', (tester) async {
    await _openApp(tester);
    await _signIn(tester);

    expect(find.text('Add class'), findsOneWidget);
  });

  testWidgets('the bottom bar switches between tabs', (tester) async {
    await _openApp(tester);
    await _signIn(tester);

    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();
    expect(find.text('Friends screen'), findsOneWidget);

    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    expect(find.text('Default reminder'), findsOneWidget);
  });
}
