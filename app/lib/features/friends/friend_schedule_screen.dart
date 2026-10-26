import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/schedule_format.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pill_chip.dart';
import '../../domain/models/class_entry.dart';
import '../../domain/models/friend.dart';

class FriendScheduleScreen extends ConsumerStatefulWidget {
  const FriendScheduleScreen({required this.friend, super.key});

  final Friend friend;

  @override
  ConsumerState<FriendScheduleScreen> createState() => _FriendScheduleScreenState();
}

class _FriendScheduleScreenState extends ConsumerState<FriendScheduleScreen> {
  int _day = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classesAsync = ref.watch(
      StreamProvider<List<ClassEntry>>((ref) =>
          ref.watch(friendScheduleRepositoryProvider).watchFriendClasses(widget.friend.friendId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friend.displayName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.friend.displayName, style: theme.textTheme.headlineMedium),
              Text('Shares timetable with you.', style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.l),

              // Day Selector
              Wrap(
                spacing: AppSpacing.s,
                children: [
                  for (var d = 1; d <= 7; d++)
                    PillChip(
                      label: weekdayInitial(d),
                      semanticLabel: weekdayName(d),
                      selected: d == _day,
                      onTap: () => setState(() => _day = d),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Class List for the Friend
              classesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => EmptyState(
                  title: 'Private schedule',
                  message: '${widget.friend.displayName} shares busy/free times only.',
                ),
                data: (classes) {
                  final todayClasses = classes.where((c) => c.days.contains(_day)).toList();

                  if (todayClasses.isEmpty) {
                    return EmptyState(
                      title: 'Free day',
                      message: '${widget.friend.displayName} has no classes on ${weekdayName(_day)}.',
                    );
                  }

                  return Column(
                    children: [
                      for (final c in todayClasses)
                        Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.m),
                          child: ListTile(
                            title: Text(c.name),
                            subtitle: Text('${formatMinutes(c.startMinute)} – ${formatMinutes(c.endMinute)}'),
                            trailing: Text(c.room ?? 'No room'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}