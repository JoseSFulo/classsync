import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(null);
      }

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
            final savedMinutes = snapshot.data()?['defaultReminderMinutes'];
            final defaultReminder = savedMinutes is int ? savedMinutes : 10;

            return _toProfile(
              user,
              defaultReminderMinutes: defaultReminder,
            );
          });
    });
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    try {
      debugPrint('[Google Sign-In] Initializing Google Sign-In...');

      await _ensureGoogleInitialized();

      debugPrint('[Google Sign-In] Opening account selection...');

      final googleUser = await _google.authenticate();

      debugPrint('[Google Sign-In] Account selected: ${googleUser.email}');

      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        debugPrint('[Google Sign-In] ERROR: ID token is null.');

        throw const UnknownFailure('Google did not return a sign-in token.');
      }

      debugPrint(
        '[Google Sign-In] ID token received. '
        'Authenticating with Firebase...',
      );

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      final result = await _auth.signInWithCredential(credential);

      final user = result.user;

      if (user == null) {
        debugPrint('[Google Sign-In] ERROR: Firebase returned no user.');

        throw const UnknownFailure('Sign-in failed. Please try again.');
      }

      debugPrint('[Google Sign-In] SUCCESS: Firebase user authenticated.');

      return _toProfile(user);
    } on AppFailure {
      rethrow;
    } on GoogleSignInException catch (e, stackTrace) {
      debugPrint('[Google Sign-In] ERROR CODE: ${e.code}');
      debugPrint('[Google Sign-In] ERROR DETAILS: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const NotSignedIn();
      }

      rethrow;
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('[Firebase Auth] ERROR CODE: ${e.code}');
      debugPrint('[Firebase Auth] ERROR MESSAGE: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);

      throw _mapFirebaseError(e);
    } catch (e, stackTrace) {
      debugPrint('[Google Sign-In] UNEXPECTED ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await _google.signOut();
    } catch (e) {
      debugPrint('[Google Sign-Out] Cleanup warning: $e');
    }

    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      debugPrint('[Firebase Sign-Out] ERROR: ${e.code} - ${e.message}');

      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw const NotSignedIn();
    }

    try {
      await user.delete();
      await signOut();
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('[Delete Account] ERROR: ${e.code} - ${e.message}');
      debugPrintStack(stackTrace: stackTrace);

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

    UserProfile _toProfile(
      User user, {
      int defaultReminderMinutes = 10,
    }) {
      return UserProfile(
        id: user.uid,
        displayName: user.displayName ?? 'Student',
        inviteCode: user.uid.length >= 6
            ? user.uid.substring(0, 6).toUpperCase()
            : 'STUDENT',
        defaultReminderMinutes: defaultReminderMinutes,
      );
    }
  }
