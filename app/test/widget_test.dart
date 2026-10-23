import 'package:classsync/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a signed-out user sees the sign-in screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ClassSyncApp()));
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('signing in opens the timetable', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ClassSyncApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('Timetable'), findsOneWidget);
  });
}
