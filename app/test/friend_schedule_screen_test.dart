import 'package:classsync/core/theme/app_theme.dart';
import 'package:classsync/features/friends/friend_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _open(WidgetTester tester, String friendId, int day) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: FriendScheduleScreen(friendId: friendId, initialDay: day),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a friend who shares everything shows class names', (
    tester,
  ) async {
    await _open(tester, 'friend-ana', 3);

    expect(find.text('Ana Ramos'), findsOneWidget);
    expect(find.text('Shares full timetable with you.'), findsOneWidget);
    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('Room 1'), findsOneWidget);
  });

  testWidgets('a friend who shares busy times only hides the details', (
    tester,
  ) async {
    await _open(tester, 'friend-maya', 3);

    expect(find.text('Shares busy and free times only.'), findsOneWidget);
    expect(find.text('Busy'), findsNWidgets(2));
    expect(find.text('Chemistry'), findsNothing);
    expect(find.text('Lab 1'), findsNothing);
  });

  testWidgets('a day with nothing shows the free-day message', (tester) async {
    await _open(tester, 'friend-ben', 6);

    expect(find.text('Free all day'), findsOneWidget);
  });
}
