import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/busy_slot.dart';
import '../../domain/models/class_entry.dart';

/// What you are allowed to see of a friend's timetable.
sealed class FriendSchedule {
  const FriendSchedule();
}

final class FullSchedule extends FriendSchedule {
  const FullSchedule(this.classes);

  final List<ClassEntry> classes;
}

final class BusySchedule extends FriendSchedule {
  const BusySchedule(this.slots);

  final List<BusySlot> slots;
}

final friendScheduleProvider = StreamProvider.family<FriendSchedule, String>((
  ref,
  friendId,
) async* {
  final repo = ref.watch(friendScheduleRepositoryProvider);
  try {
    await for (final classes in repo.watchFriendClasses(friendId)) {
      yield FullSchedule(classes);
    }
  } on PermissionDenied {
    // This friend shares busy times only.
    await for (final slots in repo.watchBusySlots(friendId)) {
      yield BusySchedule(slots);
    }
  }
});
