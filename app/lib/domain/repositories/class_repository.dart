import '../models/class_entry.dart';

abstract interface class ClassRepository {
  /// The signed-in user's classes. Works offline from the local copy.
  Stream<List<ClassEntry>> watchMyClasses();

  /// Pass a class with an empty id. Returns it with the real id.
  /// Throws [InvalidData] for bad times or days.
  Future<ClassEntry> addClass(ClassEntry draft);

  Future<void> updateClass(ClassEntry entry);

  Future<void> deleteClass(String classId);
}
