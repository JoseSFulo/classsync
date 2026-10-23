import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../domain/models/user_profile.dart';

/// The signed-in user, or null when signed out.
/// Stays in the loading state while the saved session is being checked.
final authStateProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(authRepositoryProvider).watchCurrentUser();
});
