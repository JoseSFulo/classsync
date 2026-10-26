import 'package:classsync/domain/models/class_entry.dart';
import 'package:classsync/logic/class_validation.dart';
import 'package:flutter_test/flutter_test.dart';

ClassEntry _class({
  String id = 'new',
  String name = 'Chemistry',
  List<int> days = const [1],
  int start = 540,
  int end = 600,
  int? reminder,
}) {
  return ClassEntry(
    id: id,
    name: name,
    days: days,
    startMinute: start,
    endMinute: end,
    colorValue: 0xFF2E7D6B,
    reminderMinutes: reminder,
  );
}

String? _check(ClassEntry draft, [List<ClassEntry> existing = const []]) {
  return validateClass(draft, existing: existing, defaultReminderMinutes: 10);
}

void main() {
  test('a normal class is valid', () {
    expect(_check(_class()), isNull);
  });

  test('rejects an empty name', () {
    expect(_check(_class(name: '   ')), 'Add a class name.');
  });

  test('rejects a class with no days', () {
    expect(_check(_class(days: [])), 'Pick at least one day.');
  });

  test('rejects an end time that is not after the start time', () {
    expect(_check(_class(start: 600, end: 540)), isNotNull);
    expect(_check(_class(start: 600, end: 600)), isNotNull);
  });

  test('allows a class that ends at midnight', () {
    expect(_check(_class(start: 1380, end: 1440)), isNull);
  });

  test('rejects a reminder that falls before midnight', () {
    expect(_check(_class(start: 5, end: 60)), isNotNull);
    expect(_check(_class(start: 40, end: 90, reminder: 60)), isNotNull);
  });

  test('rejects an overlap on a shared day', () {
    final other = _class(id: 'a', name: 'Physics', start: 570, end: 660);
    expect(_check(_class(), [other]), 'This overlaps with Physics.');
  });

  test('allows back-to-back classes', () {
    final other = _class(id: 'a', start: 480, end: 540);
    expect(_check(_class(start: 540, end: 600), [other]), isNull);
  });

  test('allows the same time on a different day', () {
    final other = _class(id: 'a', days: [2]);
    expect(_check(_class(days: [1]), [other]), isNull);
  });

  test('editing a class does not clash with itself', () {
    final saved = _class(id: 'a');
    expect(_check(_class(id: 'a'), [saved]), isNull);
  });
}
