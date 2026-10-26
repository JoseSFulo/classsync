import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/busy_slot.dart';
import '../../domain/models/class_entry.dart';
import '../../domain/repositories/friend_schedule_repository.dart';

/// Live implementation of [FriendScheduleRepository] backed by Firebase Firestore.
class FirestoreFriendScheduleRepository implements FriendScheduleRepository {
  FirestoreFriendScheduleRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<ClassEntry>> watchFriendClasses(String friendId) {
    return _firestore
        .collection('users')
        .doc(friendId)
        .collection('classes')
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return ClassEntry(
          id: doc.id,
          name: (data['name'] as String?) ?? '',
          days: List<int>.from((data['days'] as List?) ?? []),
          startMinute: (data['startMinute'] as int?) ?? 0,
          endMinute: (data['endMinute'] as int?) ?? 0,
          colorValue: (data['colorValue'] as int?) ?? 0xFF2E7D6B,
          room: data['room'] as String?,
          reminderMinutes: data['reminderMinutes'] as int?,
          sharedClassId: data['sharedClassId'] as String?,
        );
      }).toList();
    });
  }

  @override
  Stream<List<BusySlot>> watchBusySlots(String friendId) {
    return watchFriendClasses(friendId).map((classes) {
      final slots = <BusySlot>[];
      for (final c in classes) {
        for (final day in c.days) {
          slots.add(
            BusySlot(
              day: day,
              startMinute: c.startMinute,
              endMinute: c.endMinute,
            ),
          );
        }
      }
      return slots;
    });
  }
}