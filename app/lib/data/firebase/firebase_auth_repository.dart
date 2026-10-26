// Place this file at: lib/data/firebase/firebase_auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/failures/app_failure.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// The real implementation of [AuthRepository], backed by Firebase Auth and
/// Google Sign-In. It replaces FakeAuthRepository and has the same methods
/// the screens already call.
///
/// Rule of this project: the data layer only throws [AppFailure] subclasses
/// (NotSignedIn, Offline, UnknownFailure...), never raw Firebase errors.
/// Every Firebase/Google error is translated below.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _google = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  // google_sign_in 7.x must be initialized once before use.
  // Keeping the Future means it only runs the first time.
  Future<void>? _googleInit;
  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= _google.initialize(
      // Only add this if you get a "serverClientId must be provided" error.
      // It's the *Web* client ID from Firebase console > Authentication >
      // Sign-in method > Google > Web SDK configuration.
      // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    );
  }

  /// Emits the signed-in user, or null when signed out. Firebase also emits
  /// once at app start after checking the saved session, which is why
  /// authStateProvider shows the splash screen first.
  @override
  Stream<UserProfile?> watchCurrentUser() {
    return _auth.authStateChanges().map(
          (user) => user == null ? null : _toProfile(user),
        );
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      // 1. Opens Google's account picker. Throws if the user cancels.
      final googleUser = await _google.authenticate();

      // 2. The ID token is Google's signed proof of who the user is.
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw const UnknownFailure('Google did not return a sign-in token.');
      }

      // 3. Trade that proof for a Firebase session.
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);

      final user = result.user;
      if (user == null) {
        throw const UnknownFailure('Sign-in failed. Please try again.');
      }
      return _toProfile(user);
    } on AppFailure {
      rethrow; // already translated above, so don't wrap it again
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // The screen resets its spinner when it receives a failure,
        // so we throw instead of returning silently.
        throw const UnknownFailure('Sign-in was cancelled.');
      }
      throw const UnknownFailure('Google sign-in failed. Please try again.');
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await _google.signOut(); // forget the Google account choice
      await _auth.signOut(); // end the Firebase session
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw const NotSignedIn();
    try {
      // TODO: also delete this user's data (classes, friends) once those
      // repositories use Firestore.
      await user.delete();
      await signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const UnknownFailure(
          'For security, please sign out, sign in again, then retry.',
        );
      }
      throw _mapFirebaseError(e);
    }
  }

  /// Translates Firebase error codes into the project's AppFailure types.
  AppFailure _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return const Offline();
      case 'user-disabled':
      case 'operation-not-allowed':
        return const PermissionDenied();
      case 'user-not-found':
        return const NotSignedIn();
      default:
        return UnknownFailure(e.message ?? 'Something went wrong.');
    }
  }

  /// Converts Firebase's User into YOUR UserProfile so the rest of the app
  /// never touches Firebase types.
  UserProfile _toProfile(User user) {
    return UserProfile(
      id: user.uid,
      displayName: user.displayName ?? 'Student',
      // TEMPORARY: derived from the user id so it is stable across sign-ins.
      // For friend lookups you'll later store this in Firestore and check it
      // is unique.
      inviteCode: user.uid.substring(0, 6).toUpperCase(),
    );
  }
}