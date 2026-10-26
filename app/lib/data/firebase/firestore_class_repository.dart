import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/class_entry.dart';
import '../../domain/repositories/class_repository.dart';

/// Live implementation of [ClassRepository] backed by Firebase Firestore.
/// Implements full CRUD (Create, Read, Update, Delete) for user schedules.
class FirestoreClassRepository implements ClassRepository {
  FirestoreClassRepository(this._firestore, this._userId);

  final FirebaseFirestore _firestore;
  final String _userId;

  CollectionReference get _classesRef =>
      _firestore.collection('users').doc(_userId).collection('classes');

  // READ (Stream all classes live from Firestore)
  @override
  Stream<List<ClassEntry>> watchMyClasses() {
    return _classesRef.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
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

  // CREATE (Save new class entry)
  @override
  Future<ClassEntry> addClass(ClassEntry draft) async {
    final docRef = _classesRef.doc();
    final newClass = ClassEntry(
      id: docRef.id,
      name: draft.name,
      days: draft.days,
      startMinute: draft.startMinute,
      endMinute: draft.endMinute,
      colorValue: draft.colorValue,
      room: draft.room,
      reminderMinutes: draft.reminderMinutes,
      sharedClassId: draft.sharedClassId,
    );

    await docRef.set({
      'name': newClass.name,
      'days': newClass.days,
      'startMinute': newClass.startMinute,
      'endMinute': newClass.endMinute,
      'colorValue': newClass.colorValue,
      'room': newClass.room,
      'reminderMinutes': newClass.reminderMinutes,
      'sharedClassId': newClass.sharedClassId,
    });

    return newClass;
  }

  // UPDATE (Modify existing class entry)
  @override
  Future<void> updateClass(ClassEntry entry) async {
    await _classesRef.doc(entry.id).update({
      'name': entry.name,
      'days': entry.days,
      'startMinute': entry.startMinute,
      'endMinute': entry.endMinute,
      'colorValue': entry.colorValue,
      'room': entry.room,
      'reminderMinutes': entry.reminderMinutes,
    });
  }

  // DELETE (Remove class entry)
  @override
  Future<void> deleteClass(String classId) async {
    await _classesRef.doc(classId).delete();
  }
}