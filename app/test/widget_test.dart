import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a signed-out user sees the sign-in screen', (tester) async {
    await _openApp(tester);

    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('signing in opens the timetable', (tester) async {
    await _openApp(tester);
    await _signIn(tester);

    expect(find.text('Add class'), findsOneWidget);
  });

  testWidgets('the bottom bar switches between tabs', (tester) async {
    await _openApp(tester);
    await _signIn(tester);

    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();
    expect(find.text('Your invite code'), findsOneWidget);

    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    expect(find.text('Default reminder'), findsOneWidget);
  });
}