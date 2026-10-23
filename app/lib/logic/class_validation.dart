import '../domain/models/class_entry.dart';

/// Returns a message for the first problem found, or null if the class is fine.
///
/// Runs before anything is saved so the user gets a clear message. The data
/// layer has to enforce the same rules on its side.
String? validateClass(
  ClassEntry draft, {
  required List<ClassEntry> existing,
  required int defaultReminderMinutes,
}) {
  if (draft.name.trim().isEmpty) return 'Add a class name.';
  if (draft.days.isEmpty) return 'Pick at least one day.';
  if (draft.startMinute < 0 || draft.endMinute > 1440) {
    return 'Times must be within one day.';
  }
  if (draft.endMinute <= draft.startMinute) {
    return 'End time must be after the start time.';
  }

  final lead = draft.reminderMinutes ?? defaultReminderMinutes;
  if (draft.startMinute - lead < 0) {
    return 'That reminder falls before midnight. Choose a shorter one.';
  }

  for (final other in existing) {
    if (other.id == draft.id) continue; // editing a class never clashes with itself
    final sharesDay = other.days.any(draft.days.contains);
    final overlaps =
        draft.startMinute < other.endMinute &&
        other.startMinute < draft.endMinute;
    if (sharesDay && overlaps) return 'This overlaps with ${other.name}.';
  }
  return null;
}