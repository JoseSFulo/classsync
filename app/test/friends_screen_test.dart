import 'package:classsync/core/providers/repository_providers.dart';
import 'package:classsync/core/theme/app_theme.dart';
import 'package:classsync/core/widgets/initials_avatar.dart';
import 'package:classsync/features/friends/friends_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _open(WidgetTester tester) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await container.read(authRepositoryProvider).signInWithGoogle();

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light, home: const FriendsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapAdd(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(TextField), code);
  await tester.tap(find.text('Add'));
  await tester.pumpAndSettle();
}

void main() {
  test('initialsOf takes the first and last word', () {
    expect(initialsOf('Maya Reyes'), 'MR');
    expect(initialsOf('  ana '), 'A');
    expect(initialsOf(''), '?');
  });

  testWidgets('shows the code, the request, and the friends', (tester) async {
    await _open(tester);

    expect(find.text('JC-5T92'), findsOneWidget);
    expect(find.text('Sam Reyes'), findsOneWidget);
    expect(find.text('Maya Reyes'), findsOneWidget);
    expect(find.text('Ana Ramos'), findsOneWidget);
    expect(find.text('Ben Tan'), findsOneWidget);
  });

  testWidgets('a wrong code shows an error', (tester) async {
    await _open(tester);

    await _tapAdd(tester, 'WRONG-1');

    expect(
      find.text('No one has that code. Check it and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('your own code is rejected', (tester) async {
    await _open(tester);

    await _tapAdd(tester, 'jc-5t92');

    expect(find.text('That’s your own code.'), findsOneWidget);
  });

  testWidgets('accepting a request makes the person a friend', (tester) async {
    await _open(tester);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(find.text('Requests'), findsNothing);
    expect(find.text('Sam Reyes'), findsOneWidget);
  });

  testWidgets('turning names on asks first, turning them off does not', (
    tester,
  ) async {
    await _open(tester);

    final namesOff = find.bySemanticsLabel('Class names off for Ana');
    await tester.ensureVisible(namesOff);
    await tester.tap(namesOff);
    await tester.pumpAndSettle();
    expect(find.text('Show class names to Ana Ramos?'), findsOneWidget);

    await tester.tap(find.text('Show names'));
    await tester.pumpAndSettle();
    expect(find.text('Names on'), findsNWidgets(2));

    final namesOn = find.bySemanticsLabel('Class names on for Ana');
    await tester.ensureVisible(namesOn);
    await tester.tap(namesOn);
    await tester.pumpAndSettle();
    expect(find.textContaining('Show class names to'), findsNothing);
    expect(find.text('Names off'), findsNWidgets(2));
    expect(find.text('Names on'), findsOneWidget);
  });
}
