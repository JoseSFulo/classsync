/// Turns minutes since midnight into H:MM, so 510 becomes 8:30.
/// 1440 is allowed and shows as 24:00, for classes that end at midnight.
String formatMinutes(int minutes) {
  final safe = minutes < 0 ? 0 : (minutes > 1440 ? 1440 : minutes);
  final mins = (safe % 60).toString().padLeft(2, '0');
  return '${safe ~/ 60}:$mins';
}

const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// [day] is 1 (Monday) to 7 (Sunday), the same as everywhere else in the app.
String weekdayName(int day) => _weekdayNames[day - 1];

String weekdayInitial(int day) => 'MTWTFSS'[day - 1];
