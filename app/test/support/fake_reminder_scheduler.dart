import 'package:classsync/logic/reminder_planner.dart';
import 'package:classsync/services/notifications/reminder_scheduler.dart';

/// Stands in for the phone's notification system in tests.
class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({this.allowed = true, this.grantOnRequest = true});

  bool allowed;
  final bool grantOnRequest;
  int requestCount = 0;
  List<PlannedReminder>? lastPlan;

  @override
  Future<bool> isAllowed() async => allowed;

  @override
  Future<bool> requestPermission() async {
    requestCount++;
    allowed = grantOnRequest;
    return allowed;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    lastPlan = reminders;
  }
}
