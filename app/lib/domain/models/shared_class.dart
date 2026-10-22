class SharedClass {
  const SharedClass({
    required this.id,
    required this.ownerId,
    required this.code,
    required this.name,
    required this.days,
    required this.startMinute,
    required this.endMinute,
    this.room,
    this.cancelled = false,
  });

  final String id;
  final String ownerId;

  /// Short code classmates enter to join.
  final String code;

  final String name;
  final List<int> days;
  final int startMinute;
  final int endMinute;
  final String? room;
  final bool cancelled;
}
