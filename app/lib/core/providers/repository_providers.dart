import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/fake/fake_auth_repository.dart';
import '../../data/fake/fake_class_repository.dart';
import '../../data/fake/fake_friend_repository.dart';
import '../../data/fake/fake_friend_schedule_repository.dart';
import '../../data/fake/fake_settings_repository.dart';
import '../../data/fake/fake_shared_class_repository.dart';
import '../../data/firebase/firebase_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/friend_repository.dart';
import '../../domain/repositories/friend_schedule_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/shared_class_repository.dart';

// Swap these fakes for the real Firebase classes when they are ready.

// Still needed ONLY because FakeSettingsRepository is built from it.
// Remove this once settings has a real implementation.
final _fakeAuthProvider = Provider<FakeAuthRepository>(
  (ref) => FakeAuthRepository(),
);

// REAL Google sign-in through Firebase (was: ref.watch(_fakeAuthProvider)).
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => FakeSettingsRepository(ref.watch(_fakeAuthProvider)),
);

final classRepositoryProvider = Provider<ClassRepository>(
  (ref) => FakeClassRepository(),
);

final friendRepositoryProvider = Provider<FriendRepository>(
  (ref) => FakeFriendRepository(),
);

final friendScheduleRepositoryProvider = Provider<FriendScheduleRepository>(
  (ref) => FakeFriendScheduleRepository(),
);

final sharedClassRepositoryProvider = Provider<SharedClassRepository>(
  (ref) => FakeSharedClassRepository(),
);