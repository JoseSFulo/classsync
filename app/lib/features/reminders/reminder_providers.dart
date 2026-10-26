import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic/reminder_planner.dart';
import '../../services/notifications/local_notification_scheduler.dart';
import '../../services/notifications/reminder_scheduler.dart';
import '../auth/auth_providers.dart';
import '../timetable/timetable_providers.dart';

/// Tests replace this with a fake.
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => LocalNotificationScheduler(),
);

/// Whether the phone currently allows notifications.
final reminderAccessProvider = FutureProvider<bool>(
  (ref) => ref.watch(reminderSchedulerProvider).isAllowed(),
);

/// Remembers whether the explanation was already shown in this app session.
class ReminderOffer {
  bool shown = false;
}

final reminderOfferProvider = Provider<ReminderOffer>((ref) => ReminderOffer());

/// Keeps scheduled reminders in step with the classes, the default lead
/// time, and who is signed in. Watched once, from the app widget.
final reminderSyncProvider = Provider<void>((ref) {
  final scheduler = ref.watch(reminderSchedulerProvider);
  final auth = ref.watch(authStateProvider);

  // Still checking for a saved session: leave existing reminders alone.
  if (!auth.hasValue) {
    return;
  }

  final profile = auth.value;
  if (profile == null) {
    unawaited(_apply(scheduler, const []));
    return;
  }

  final classes = ref.watch(myClassesProvider).value;
  if (classes == null) {
    return;
  }

  final plan = planReminders(
    classes: classes,
    defaultReminderMinutes: profile.defaultReminderMinutes,
    now: DateTime.now(),
  );
  unawaited(_apply(scheduler, plan));
});

Future<void> _apply(
  ReminderScheduler scheduler,
  List<PlannedReminder> plan,
) async {
  try {
    // Nothing to show if the phone blocks notifications.
    if (plan.isNotEmpty && !await scheduler.isAllowed()) {
      return;
    }
    await scheduler.replaceAll(plan);
  } catch (error) {
    debugPrint('Could not update reminders: $error');
  }
}
