import 'package:classsync/core/utils/schedule_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatMinutes writes hours and padded minutes', () {
    expect(formatMinutes(510), '8:30');
    expect(formatMinutes(0), '0:00');
    expect(formatMinutes(1050), '17:30');
  });

  test('formatMinutes keeps out-of-range values inside one day', () {
    expect(formatMinutes(-30), '0:00');
    expect(formatMinutes(2000), '23:59');
  });

  test('weekday helpers start on Monday', () {
    expect(weekdayName(1), 'Monday');
    expect(weekdayName(7), 'Sunday');
    expect(weekdayInitial(3), 'W');
  });
}
