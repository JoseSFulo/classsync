import '../core/utils/schedule_format.dart';
import '../domain/models/class_entry.dart';

/// How many days ahead reminders are scheduled. The app refreshes the window
/// every time it opens and whenever classes change.
const reminderWindowDays = 7;

/// iOS keeps at most 64 pending notifications, so we stay below that.
const maxScheduledReminders = 60;

class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });

  /// 0, 1, 2... in time order. Safe to reuse because every refresh cancels
  /// all pending reminders before scheduling the new set.
  final int id;

  /// Local time the reminder should appear.
  final DateTime at;
  final String title;
  final String body;
}

/// Works out which reminders should be scheduled from [now] onwards.
List<PlannedReminder> planReminders({
  required List<ClassEntry> classes,
  required int defaultReminderMinutes,
  required DateTime now,
  int days = reminderWindowDays,
  int maxCount = maxScheduledReminders,
}) {
  final found = <({DateTime at, ClassEntry entry})>[];

  for (var offset = 0; offset < days; offset++) {
    final day = DateTime(now.year, now.month, now.day + offset);

    for (final entry in classes) {
      if (!entry.days.contains(day.weekday)) {
        continue;
      }

      final lead = entry.reminderMinutes ?? defaultReminderMinutes;
      final alarmMinute = entry.startMinute - lead;

      // Smart check: Is there a previous class that bleeds into our alarm time?
      final isBackToBack = classes.any(
        (other) =>
            other.id != entry.id &&
            other.days.contains(day.weekday) &&
            other.startMinute <=
                entry.startMinute && // Class starts before or at the same time
            other.endMinute >
                alarmMinute, // Class ends AFTER our alarm is supposed to ring
      );

      if (isBackToBack) {
        continue; // Skip this alarm, you are already in a class
      }

      final at = DateTime(day.year, day.month, day.day, 0, alarmMinute);

      if (at.isAfter(now)) {
        found.add((at: at, entry: entry));
      }
    }
  }

  found.sort((a, b) => a.at.compareTo(b.at));
  final chosen = found.take(maxCount).toList();

  return [
    for (var i = 0; i < chosen.length; i++)
      PlannedReminder(
        id: i,
        at: chosen[i].at,
        title: chosen[i].entry.name,
        body: _body(chosen[i].entry),
      ),
  ];
}

String _body(ClassEntry entry) {
  final room = entry.room;
  final start = 'Starts at ${formatMinutes(entry.startMinute)}';
  return room == null || room.isEmpty ? start : '$start · $room';
}
