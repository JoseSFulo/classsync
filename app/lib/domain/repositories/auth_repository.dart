import '../models/user_profile.dart';

abstract interface class AuthRepository {
  /// Emits the signed-in user's profile, or null when signed out.
  /// Also restores the saved session when the app starts.
  Stream<UserProfile?> watchCurrentUser();

  /// Throws [NotSignedIn] if the user cancels, [Offline] without internet.
  Future<UserProfile> signInWithGoogle();

  Future<void> signOut();

  /// Deletes the account and all of the user's data.
  Future<void> deleteAccount();
}
