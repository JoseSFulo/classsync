import 'package:classsync/domain/models/class_entry.dart';
import 'package:classsync/logic/reminder_planner.dart';
import 'package:flutter_test/flutter_test.dart';

ClassEntry _class({
  String id = 'a',
  String name = 'Calculus',
  List<int> days = const [1, 3, 5],
  int start = 480,
  int? reminder,
  String? room,
}) {
  return ClassEntry(
    id: id,
    name: name,
    days: days,
    startMinute: start,
    endMinute: start + 60,
    colorValue: 0xFF2E7D6B,
    reminderMinutes: reminder,
    room: room,
  );
}

// Monday 19 October 2026, 07:00.
final _monday = DateTime(2026, 10, 19, 7);

List<PlannedReminder> _plan(
  List<ClassEntry> classes, {
  DateTime? now,
  int maxCount = 60,
}) {
  return planReminders(
    classes: classes,
    defaultReminderMinutes: 10,
    now: now ?? _monday,
    maxCount: maxCount,
  );
}

void main() {
  test('plans one reminder per class day in the next 7 days', () {
    final plan = _plan([_class()]);

    expect(plan.map((r) => r.at), [
      DateTime(2026, 10, 19, 7, 50),
      DateTime(2026, 10, 21, 7, 50),
      DateTime(2026, 10, 23, 7, 50),
    ]);
  });

  test('skips reminders that are already in the past', () {
    final plan = _plan([_class()], now: DateTime(2026, 10, 19, 8));

    expect(plan.length, 2);
    expect(plan.first.at, DateTime(2026, 10, 21, 7, 50));
  });

  test('a per-class reminder overrides the default', () {
    final plan = _plan([_class(reminder: 30)]);

    expect(plan.first.at, DateTime(2026, 10, 19, 7, 30));
  });

  test('reminders are sorted by time and numbered from zero', () {
    final plan = _plan([
      _class(id: 'a', name: 'Calculus', days: [1], start: 480),
      _class(id: 'b', name: 'Biology', days: [1], start: 450),
    ]);

    expect(plan.map((r) => r.title), ['Biology', 'Calculus']);
    expect(plan.map((r) => r.id), [0, 1]);
  });

  test('keeps only the earliest reminders when over the limit', () {
    final plan = _plan([_class()], maxCount: 2);

    expect(plan.length, 2);
    expect(plan.last.at, DateTime(2026, 10, 21, 7, 50));
  });

  test('the message shows the start time and the room', () {
    final plan = _plan([_class(room: 'Room 204')]);

    expect(plan.first.body, 'Starts at 8:00 · Room 204');
  });

  test('no classes means no reminders', () {
    expect(_plan([]), isEmpty);
  });
}
