import '../../domain/failures/app_failure.dart';
import '../../domain/models/busy_slot.dart';
import '../../domain/models/class_entry.dart';
import '../../domain/repositories/friend_schedule_repository.dart';

class FakeFriendScheduleRepository implements FriendScheduleRepository {
  // Only Ana shares her full timetable with you. For the others you only
  // get busy times, like the real rules will allow.
  static const _sharesFull = {'friend-ana'};

  static const _classes = <String, List<ClassEntry>>{
    'friend-maya': [
      ClassEntry(
        id: 'maya-1',
        name: 'Biology',
        days: [1],
        startMinute: 480,
        endMinute: 600,
        colorValue: 0xFF2E7D6B,
        room: 'Room 12',
      ),
      ClassEntry(
        id: 'maya-2',
        name: 'Chemistry',
        days: [3],
        startMinute: 540,
        endMinute: 720,
        colorValue: 0xFF4A7FD1,
        room: 'Lab 1',
      ),
      ClassEntry(
        id: 'maya-3',
        name: 'Economics',
        days: [3],
        startMinute: 780,
        endMinute: 900,
        colorValue: 0xFFE08A3C,
        room: 'Hall B',
      ),
      ClassEntry(
        id: 'maya-4',
        name: 'Statistics',
        days: [4],
        startMinute: 600,
        endMinute: 720,
        colorValue: 0xFFB867C6,
        room: 'Room 8',
      ),
    ],
    'friend-ana': [
      ClassEntry(
        id: 'ana-1',
        name: 'Algebra',
        days: [3],
        startMinute: 480,
        endMinute: 600,
        colorValue: 0xFF2E7D6B,
        room: 'Room 1',
      ),
      ClassEntry(
        id: 'ana-2',
        name: 'History',
        days: [3],
        startMinute: 720,
        endMinute: 840,
        colorValue: 0xFFE08A3C,
        room: 'Room 7',
      ),
      ClassEntry(
        id: 'ana-3',
        name: 'Art',
        days: [3],
        startMinute: 900,
        endMinute: 1020,
        colorValue: 0xFFD9576B,
        room: 'Studio 2',
      ),
    ],
    'friend-ben': [
      ClassEntry(
        id: 'ben-1',
        name: 'Physics',
        days: [3],
        startMinute: 600,
        endMinute: 660,
        colorValue: 0xFF4A7FD1,
        room: 'Room 3',
      ),
      ClassEntry(
        id: 'ben-2',
        name: 'Writing',
        days: [3],
        startMinute: 840,
        endMinute: 960,
        colorValue: 0xFFB867C6,
        room: 'Room 9',
      ),
    ],
  };

  @override
  Stream<List<BusySlot>> watchBusySlots(String friendId) {
    final classes = _classes[friendId];
    if (classes == null) {
      return Stream<List<BusySlot>>.error(const NotFound('Friend not found.'));
    }
    return Stream.value([
      for (final c in classes)
        for (final day in c.days)
          BusySlot(
            day: day,
            startMinute: c.startMinute,
            endMinute: c.endMinute,
          ),
    ]);
  }

  @override
  Stream<List<ClassEntry>> watchFriendClasses(String friendId) {
    final classes = _classes[friendId];
    if (classes == null) {
      return Stream<List<ClassEntry>>.error(
        const NotFound('Friend not found.'),
      );
    }
    if (!_sharesFull.contains(friendId)) {
      return Stream<List<ClassEntry>>.error(const PermissionDenied());
    }
    return Stream.value(classes);
  }
}
