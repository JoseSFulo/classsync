import '../../domain/failures/app_failure.dart';
import '../../domain/models/shared_class.dart';
import '../../domain/repositories/shared_class_repository.dart';
import 'fake_store.dart';

class FakeSharedClassRepository implements SharedClassRepository {
  final _store = FakeStore<List<SharedClass>>(const <SharedClass>[]);
  int _nextId = 1;

  @override
  Stream<List<SharedClass>> watchSharedClasses() => _store.watch();

  @override
  Future<SharedClass> createSharedClass(SharedClass draft) async {
    final id = 'shared-${_nextId++}';
    final saved = SharedClass(
      id: id,
      ownerId: draft.ownerId,
      code: 'CODE$id',
      name: draft.name,
      days: draft.days,
      startMinute: draft.startMinute,
      endMinute: draft.endMinute,
      room: draft.room,
    );
    _store.value = [..._store.value, saved];
    return saved;
  }

  @override
  Future<SharedClass> joinByCode(String code) async {
    if (code != 'MATH101') throw const NotFound('No class has that code.');
    if (_store.value.any((s) => s.code == code)) {
      throw const AlreadyExists('You already joined this class.');
    }
    const joined = SharedClass(
      id: 'shared-math',
      ownerId: 'friend-1',
      code: 'MATH101',
      name: 'Math 101',
      days: [2, 4],
      startMinute: 840,
      endMinute: 930,
      room: 'Room 12',
    );
    _store.value = [..._store.value, joined];
    return joined;
  }

  @override
  Future<void> updateSharedClass(SharedClass sharedClass) async {
    _store.value = [
      for (final s in _store.value)
        if (s.id == sharedClass.id) sharedClass else s,
    ];
  }

  @override
  Future<void> leaveSharedClass(String sharedClassId) async {
    _store.value = [
      for (final s in _store.value)
        if (s.id != sharedClassId) s,
    ];
  }
}
