import 'package:classsync/data/fake/fake_class_repository.dart';
import 'package:classsync/domain/failures/app_failure.dart';
import 'package:classsync/domain/models/class_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('addClass stores a valid class', () async {
    final repo = FakeClassRepository();
    final before = (await repo.watchMyClasses().first).length;

    await repo.addClass(
      const ClassEntry(
        id: '',
        name: 'Physics',
        days: [5],
        startMinute: 540,
        endMinute: 600,
        colorValue: 0xFFFF9800,
      ),
    );

    expect((await repo.watchMyClasses().first).length, before + 1);
  });

  test('addClass rejects an end time before the start time', () async {
    final repo = FakeClassRepository();

    await expectLater(
      repo.addClass(
        const ClassEntry(
          id: '',
          name: 'Bad',
          days: [1],
          startMinute: 600,
          endMinute: 540,
          colorValue: 0xFF000000,
        ),
      ),
      throwsA(isA<InvalidData>()),
    );
  });
}
