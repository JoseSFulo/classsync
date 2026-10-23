import 'package:classsync/core/utils/schedule_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatMinutes writes hours and padded minutes', () {
    expect(formatMinutes(510), '8:30');
    expect(formatMinutes(0), '0:00');
    expect(formatMinutes(1050), '17:30');
  });

  test('formatMinutes shows midnight as 24:00 and clamps beyond that', () {
    expect(formatMinutes(1440), '24:00');
    expect(formatMinutes(-30), '0:00');
    expect(formatMinutes(2000), '24:00');
  });

  test('weekday helpers start on Monday', () {
    expect(weekdayName(1), 'Monday');
    expect(weekdayName(7), 'Sunday');
    expect(weekdayInitial(3), 'W');
  });
}
