import 'package:classsync/core/providers/repository_providers.dart';
import 'package:classsync/features/reminders/reminder_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_reminder_scheduler.dart';

void main() {
  test('signing in schedules reminders and signing out clears them', () async {
    final scheduler = FakeReminderScheduler();
    final container = ProviderContainer(
      overrides: [reminderSchedulerProvider.overrideWithValue(scheduler)],
    );
    addTearDown(container.dispose);
    container.listen(reminderSyncProvider, (_, _) {});

    final auth = container.read(authRepositoryProvider);
    await auth.signInWithGoogle();
    await pumpEventQueue();
    expect(scheduler.lastPlan, isNotEmpty);

    await auth.signOut();
    await pumpEventQueue();
    expect(scheduler.lastPlan, isEmpty);
  });

  test('nothing is scheduled while notifications are blocked', () async {
    final scheduler = FakeReminderScheduler(allowed: false);
    final container = ProviderContainer(
      overrides: [reminderSchedulerProvider.overrideWithValue(scheduler)],
    );
    addTearDown(container.dispose);
    container.listen(reminderSyncProvider, (_, _) {});

    await container.read(authRepositoryProvider).signInWithGoogle();
    await pumpEventQueue();

    expect(scheduler.lastPlan, isNull);
  });
}
