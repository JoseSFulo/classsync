import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../domain/models/class_entry.dart';

/// The signed-in user's classes. Updates by itself when they change.
final myClassesProvider = StreamProvider<List<ClassEntry>>((ref) {
  return ref.watch(classRepositoryProvider).watchMyClasses();
});
