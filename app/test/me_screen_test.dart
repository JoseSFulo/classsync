import 'package:classsync/core/providers/repository_providers.dart';
import 'package:classsync/core/theme/app_theme.dart';
import 'package:classsync/features/auth/auth_providers.dart';
import 'package:classsync/features/settings/me_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:classsync/features/reminders/reminder_providers.dart';

import 'support/fake_reminder_scheduler.dart';

Future<ProviderContainer> _openSignedIn(WidgetTester tester) async {
  final container = ProviderContainer(
    overrides: [
      reminderSchedulerProvider.overrideWithValue(FakeReminderScheduler()),
    ],
  );
  addTearDown(container.dispose);
  await container.read(authRepositoryProvider).signInWithGoogle();

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light, home: const MeScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('changing the default reminder updates the profile', (
    tester,
  ) async {
    final container = await _openSignedIn(tester);

    expect(find.text('Demo Student'), findsOneWidget);
    await tester.tap(find.text('30 min'));
    await tester.pumpAndSettle();

    expect(container.read(authStateProvider).value?.defaultReminderMinutes, 30);
  });

  testWidgets('signing out clears the user', (tester) async {
    final container = await _openSignedIn(tester);

    await tester.ensureVisible(find.text('Sign out'));
    await tester.tap(find.text('Sign out'));
    // A plain pump, because the spinner shown after sign-out never settles.
    await tester.pump();
    await tester.pump();

    expect(container.read(authStateProvider).value, isNull);
  });
}
