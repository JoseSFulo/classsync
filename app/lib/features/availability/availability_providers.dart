import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/busy_slot.dart';
import '../timetable/timetable_providers.dart';
import '../friends/friend_schedule_providers.dart';

class TimeWindow {
  const TimeWindow(this.startMinute, this.endMinute);
  final int startMinute;
  final int endMinute;
}

final mutualFreeTimeProvider = Provider.family<AsyncValue<List<TimeWindow>>, ({String friendId, int day})>((ref, args) {
  final myClassesAsync = ref.watch(myClassesProvider);
  final friendScheduleAsync = ref.watch(friendScheduleProvider(args.friendId));

  if (myClassesAsync.isLoading || friendScheduleAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (myClassesAsync.hasError) return AsyncValue.error(myClassesAsync.error!, myClassesAsync.stackTrace!);
  if (friendScheduleAsync.hasError) return AsyncValue.error(friendScheduleAsync.error!, friendScheduleAsync.stackTrace!);

  final myClasses = myClassesAsync.value ?? [];
  final friendSchedule = friendScheduleAsync.value;

  // 1. Gather all busy times for the specific day
  final busyTimes = <TimeWindow>[];
  
  // Add my busy times
  for (final c in myClasses.where((c) => c.days.contains(args.day))) {
    busyTimes.add(TimeWindow(c.startMinute, c.endMinute));
  }

  // Add friend's busy times
  if (friendSchedule != null) {
    switch (friendSchedule) {
      case FullSchedule(:final classes):
        for (final c in classes.where((c) => c.days.contains(args.day))) {
          busyTimes.add(TimeWindow(c.startMinute, c.endMinute));
        }
      case BusySchedule(:final slots):
        for (final s in slots.where((s) => s.day == args.day)) {
          busyTimes.add(TimeWindow(s.startMinute, s.endMinute));
        }
    }
  }

  // 2. Sort and merge overlapping busy blocks
  busyTimes.sort((a, b) => a.startMinute.compareTo(b.startMinute));
  final mergedBusy = <TimeWindow>[];
  
  for (final current in busyTimes) {
    if (mergedBusy.isEmpty) {
      mergedBusy.add(current);
    } else {
      final last = mergedBusy.last;
      if (current.startMinute <= last.endMinute) {
        // Overlapping or touching: merge them
        mergedBusy[mergedBusy.length - 1] = TimeWindow(
          last.startMinute,
          max(last.endMinute, current.endMinute),
        );
      } else {
        mergedBusy.add(current);
      }
    }
  }

  // 3. Find the gaps (Free Time) between 8:00 AM (480) and 5:00 PM (1020)
  const dayStart = 480;
  const dayEnd = 1020;
  final freeTimes = <TimeWindow>[];
  var currentTime = dayStart;

  for (final busy in mergedBusy) {
    if (busy.startMinute > currentTime) {
      // Gap found before the next busy block
      final freeEnd = min(busy.startMinute, dayEnd);
      if (freeEnd - currentTime >= 30) { // Only show gaps of 30+ mins
        freeTimes.add(TimeWindow(currentTime, freeEnd));
      }
    }
    currentTime = max(currentTime, busy.endMinute);
  }

  // Check for free time after the last class until dayEnd
  if (currentTime < dayEnd && (dayEnd - currentTime >= 30)) {
    freeTimes.add(TimeWindow(currentTime, dayEnd));
  }

  return AsyncValue.data(freeTimes);
});