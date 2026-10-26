import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/busy_slot.dart';
import '../domain/models/class_entry.dart';

class FreeTimeSlot {
  final int startMinute;
  final int endMinute;
  FreeTimeSlot(this.startMinute, this.endMinute);
}

final mutualAvailabilityProvider =
    Provider.family<
      List<FreeTimeSlot>,
      ({List<ClassEntry> myClasses, List<BusySlot> friendSlots, int day})
    >((ref, args) {
      const dayStart = 480; // 8:00 AM
      const dayEnd = 1020; // 5:00 PM

      List<bool> timeline = List.filled(1440, false);

      for (final c in args.myClasses.where((c) => c.days.contains(args.day))) {
        for (int m = c.startMinute; m < c.endMinute; m++) {
          timeline[m] = true;
        }
      }

      for (final slot in args.friendSlots.where((s) => s.day == args.day)) {
        for (int m = slot.startMinute; m < slot.endMinute; m++) {
          timeline[m] = true;
        }
      }

      List<FreeTimeSlot> freeSlots = [];
      int? currentStart;

      for (int m = dayStart; m <= dayEnd; m++) {
        if (!timeline[m] && currentStart == null) {
          currentStart = m;
        } else if (timeline[m] && currentStart != null) {
          if (m - currentStart >= 30) {
            freeSlots.add(FreeTimeSlot(currentStart, m));
          }
          currentStart = null;
        }
      }

      if (currentStart != null && dayEnd - currentStart >= 30) {
        freeSlots.add(FreeTimeSlot(currentStart, dayEnd));
      }

      return freeSlots;
    });
