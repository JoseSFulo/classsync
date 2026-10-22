/// A time range someone is busy. It never carries a class name or room.
class BusySlot {
  const BusySlot({
    required this.day,
    required this.startMinute,
    required this.endMinute,
  });

  /// 1 (Monday) to 7 (Sunday).
  final int day;
  final int startMinute;
  final int endMinute;

  @override
  bool operator ==(Object other) =>
      other is BusySlot &&
      other.day == day &&
      other.startMinute == startMinute &&
      other.endMinute == endMinute;

  @override
  int get hashCode => Object.hash(day, startMinute, endMinute);
}
