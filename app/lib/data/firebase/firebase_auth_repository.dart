import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/failures/app_failure.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({this.firebaseAuth, this.googleSignIn});

  final FirebaseAuth? firebaseAuth;
  final GoogleSignIn? googleSignIn;

  FirebaseAuth get _auth => firebaseAuth ?? FirebaseAuth.instance;
  GoogleSignIn get _google => googleSignIn ?? GoogleSignIn.instance;

  Future<void>? _googleInit;
  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= _google.initialize();
  }

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

      final googleUser = await _google.authenticate();

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw const UnknownFailure('Google did not return a sign-in token.');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);

      final user = result.user;
      if (user == null) {
        throw const UnknownFailure('Sign-in failed. Please try again.');
      }
      return _toProfile(user);
    } on AppFailure {
      rethrow;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const NotSignedIn();
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
      await _google.signOut();
    } catch (_) {
      // Ignore Google cleanup errors
    }

    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw const NotSignedIn();
    try {
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

  UserProfile _toProfile(User user) {
    return UserProfile(
      id: user.uid,
      displayName: user.displayName ?? 'Student',
      inviteCode: user.uid.length >= 6
          ? user.uid.substring(0, 6).toUpperCase()
          : 'STUDENT',
    );
  }
}
