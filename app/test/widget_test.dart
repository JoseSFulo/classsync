import 'package:classsync/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app opens on the timetable route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ClassSyncApp()));
    await tester.pumpAndSettle();

    expect(find.text('Timetable'), findsOneWidget);
  });
}
