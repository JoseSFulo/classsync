import '../../domain/failures/app_failure.dart';
import '../../domain/models/class_entry.dart';
import '../../domain/repositories/class_repository.dart';
import 'fake_store.dart';

class FakeClassRepository implements ClassRepository {
  final _store = FakeStore<List<ClassEntry>>(const <ClassEntry>[
    ClassEntry(
      id: 'class-1',
      name: 'Calculus',
      days: [1, 3, 5],
      startMinute: 480,
      endMinute: 570,
      colorValue: 0xFF2E7D6B,
      room: 'Room 204',
    ),
    ClassEntry(
      id: 'class-2',
      name: 'Programming',
      days: [2, 4],
      startMinute: 780,
      endMinute: 870,
      colorValue: 0xFFB867C6,
      room: 'Lab 5',
    ),
    ClassEntry(
      id: 'class-3',
      name: 'Physics Lab',
      days: [3],
      startMinute: 600,
      endMinute: 720,
      colorValue: 0xFF4A7FD1,
      room: 'Science Bldg · Lab 3',
    ),
    ClassEntry(
      id: 'class-4',
      name: 'Intro to Design',
      days: [2, 3],
      startMinute: 960,
      endMinute: 1050,
      colorValue: 0xFFE08A3C,
      room: 'Studio B',
      reminderMinutes: 30,
    ),
  ]);

  int _nextId = 5;

  @override
  Stream<List<ClassEntry>> watchMyClasses() => _store.watch();

  @override
  Future<ClassEntry> addClass(ClassEntry draft) async {
    _validate(draft);
    final saved = ClassEntry(
      id: 'class-${_nextId++}',
      name: draft.name,
      days: draft.days,
      startMinute: draft.startMinute,
      endMinute: draft.endMinute,
      colorValue: draft.colorValue,
      room: draft.room,
      reminderMinutes: draft.reminderMinutes,
      sharedClassId: draft.sharedClassId,
    );
    _store.value = [..._store.value, saved];
    return saved;
  }

  @override
  Future<void> updateClass(ClassEntry entry) async {
    _validate(entry);
    _store.value = [
      for (final c in _store.value)
        if (c.id == entry.id) entry else c,
    ];
  }

  @override
  Future<void> deleteClass(String classId) async {
    _store.value = [
      for (final c in _store.value)
        if (c.id != classId) c,
    ];
  }

  void _validate(ClassEntry c) {
    final badDay = c.days.any((d) => d < 1 || d > 7);
    if (c.name.trim().isEmpty ||
        c.days.isEmpty ||
        badDay ||
        c.startMinute < 0 ||
        c.endMinute > 1440 ||
        c.endMinute <= c.startMinute) {
      throw const InvalidData('Check the name, days, and times.');
    }
  }
}
