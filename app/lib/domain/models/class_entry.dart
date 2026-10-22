class ClassEntry {
  const ClassEntry({
    required this.id,
    required this.name,
    required this.days,
    required this.startMinute,
    required this.endMinute,
    required this.colorValue,
    this.room,
    this.reminderMinutes,
    this.sharedClassId,
  });

  final String id;
  final String name;

  /// Weekdays this class repeats on, 1 (Monday) to 7 (Sunday).
  final List<int> days;

  /// Minutes since midnight. 8:30 AM is 510.
  final int startMinute;
  final int endMinute;

  /// Color as an ARGB integer, for example 0xFF4CAF50.
  final int colorValue;

  final String? room;

  /// Overrides the default reminder. Null means use the default.
  final int? reminderMinutes;

  /// Set when this class was joined from a shared class.
  final String? sharedClassId;
}
