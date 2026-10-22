import '../models/shared_class.dart';

abstract interface class SharedClassRepository {
  /// Shared classes I created or joined. Updates live when the owner edits.
  Stream<List<SharedClass>> watchSharedClasses();

  /// Pass a class with an empty id and code. Returns it with both filled in.
  Future<SharedClass> createSharedClass(SharedClass draft);

  /// Throws [NotFound] for a wrong code, [AlreadyExists] if already joined.
  Future<SharedClass> joinByCode(String code);

  /// Owner only. Throws [PermissionDenied] for anyone else.
  Future<void> updateSharedClass(SharedClass sharedClass);

  Future<void> leaveSharedClass(String sharedClassId);
}
