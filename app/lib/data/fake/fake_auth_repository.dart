import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import 'fake_store.dart';

class FakeAuthRepository implements AuthRepository {
  /// Starts signed out. Shared with [FakeSettingsRepository].
  final store = FakeStore<UserProfile?>(null);

  @override
  Stream<UserProfile?> watchCurrentUser() => store.watch();

  @override
  Future<UserProfile> signInWithGoogle() async {
    const profile = UserProfile(
      id: 'user-1',
      displayName: 'Demo Student',
      inviteCode: 'DEMO',
    );
    store.value = profile;
    return profile;
  }

  @override
  Future<void> signOut() async => store.value = null;

  @override
  Future<void> deleteAccount() async => store.value = null;
}
