import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/fake/fake_class_repository.dart';
import '../../data/fake/fake_friend_repository.dart';
import '../../data/fake/fake_friend_schedule_repository.dart';
import '../../data/fake/fake_shared_class_repository.dart';
import '../../data/firebase/firebase_auth_repository.dart';
import '../../data/firebase/firestore_class_repository.dart';
import '../../data/firebase/firestore_settings_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/friend_repository.dart';
import '../../domain/repositories/friend_schedule_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/shared_class_repository.dart';
import '../../features/auth/auth_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => FirestoreSettingsRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  ),
);

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return FakeClassRepository();
  }
  return FirestoreClassRepository(FirebaseFirestore.instance, user.id);
});

final friendRepositoryProvider = Provider<FriendRepository>(
  (ref) => FakeFriendRepository(),
);

final friendScheduleRepositoryProvider = Provider<FriendScheduleRepository>(
  (ref) => FakeFriendScheduleRepository(),
);

final sharedClassRepositoryProvider = Provider<SharedClassRepository>(
  (ref) => FakeSharedClassRepository(),
);