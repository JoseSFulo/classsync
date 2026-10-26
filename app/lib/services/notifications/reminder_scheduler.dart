import '../../logic/reminder_planner.dart';

/// What the app needs from the phone's notification system.
/// Screens and providers use this, never the plugin directly.
abstract interface class ReminderScheduler {
  /// True if the phone currently allows notifications from this app.
  Future<bool> isAllowed();

  /// Shows the system permission dialog. Returns whether it was granted.
  Future<bool> requestPermission();

  /// Cancels every pending reminder, then schedules [reminders].
  Future<void> replaceAll(List<PlannedReminder> reminders);
}
