import '../models/busy_slot.dart';
import '../models/class_entry.dart';

abstract interface class FriendScheduleRepository {
  /// A friend's busy times. Allowed for every accepted friend.
  /// Throws [PermissionDenied] if you are not friends.
  Stream<List<BusySlot>> watchBusySlots(String friendId);

  /// A friend's full classes. Throws [PermissionDenied] unless the friend
  /// set their sharing level to full for you.
  Stream<List<ClassEntry>> watchFriendClasses(String friendId);
}
