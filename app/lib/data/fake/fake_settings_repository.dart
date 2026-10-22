import '../../domain/models/user_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import 'fake_auth_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository(this._auth);

  final FakeAuthRepository _auth;

  @override
  Future<void> setDefaultReminderMinutes(int minutes) async {
    final current = _auth.store.value;
    if (current == null) return;
    _auth.store.value = UserProfile(
      id: current.id,
      displayName: current.displayName,
      photoUrl: current.photoUrl,
      inviteCode: current.inviteCode,
      defaultReminderMinutes: minutes,
    );
  }
}
