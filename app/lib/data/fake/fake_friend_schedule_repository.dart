import '../../domain/failures/app_failure.dart';
import '../../domain/models/busy_slot.dart';
import '../../domain/models/class_entry.dart';
import '../../domain/repositories/friend_schedule_repository.dart';

class FakeFriendScheduleRepository implements FriendScheduleRepository {
  @override
  Stream<List<BusySlot>> watchBusySlots(String friendId) {
    return Stream.value(const <BusySlot>[
      BusySlot(day: 1, startMinute: 540, endMinute: 660),
      BusySlot(day: 3, startMinute: 780, endMinute: 900),
    ]);
  }

  @override
  Stream<List<ClassEntry>> watchFriendClasses(String friendId) {
    return Stream<List<ClassEntry>>.error(const PermissionDenied());
  }
}
