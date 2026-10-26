import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/fake/fake_auth_repository.dart';
import '../../data/fake/fake_class_repository.dart';
import '../../data/fake/fake_friend_repository.dart';
import '../../data/fake/fake_friend_schedule_repository.dart';
import '../../data/fake/fake_settings_repository.dart';
import '../../data/fake/fake_shared_class_repository.dart';
import '../../data/firebase/firebase_auth_repository.dart';
import '../../data/firebase/firestore_class_repository.dart';
import '../../data/firebase/firestore_friend_repository.dart';
import '../../data/firebase/firestore_friend_schedule_repository.dart';
import '../../data/firebase/firestore_settings_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/friend_repository.dart';
import '../../domain/repositories/friend_schedule_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/shared_class_repository.dart';
import '../../features/auth/auth_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (Firebase.apps.isEmpty) {
    return FakeAuthRepository();
  }
  return FirebaseAuthRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  if (Firebase.apps.isEmpty) {
    final auth = ref.watch(authRepositoryProvider);
    // Safely check the type instead of forcing a hard cast
    return FakeSettingsRepository(
      auth is FakeAuthRepository ? auth : FakeAuthRepository(),
    );
  }
  return FirestoreSettingsRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  if (Firebase.apps.isEmpty) {
    return FakeClassRepository();
  }
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return FakeClassRepository();
  }
  return FirestoreClassRepository(FirebaseFirestore.instance, user.id);
});

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  if (Firebase.apps.isEmpty) {
    return FakeFriendRepository();
  }
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return FakeFriendRepository();
  }
  return FirestoreFriendRepository(FirebaseFirestore.instance, user.id);
});

final friendScheduleRepositoryProvider = Provider<FriendScheduleRepository>((ref) {
  if (Firebase.apps.isEmpty) {
    return FakeFriendScheduleRepository();
  }
  return FirestoreFriendScheduleRepository(FirebaseFirestore.instance);
});

final sharedClassRepositoryProvider = Provider<SharedClassRepository>(
  (ref) => FakeSharedClassRepository(),
);