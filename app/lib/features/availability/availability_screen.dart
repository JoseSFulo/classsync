import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/schedule_format.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pill_chip.dart';
import '../../domain/models/busy_slot.dart';
import '../../domain/models/friend.dart';
import '../../features/timetable/timetable_providers.dart';
import '../../logic/availability_provider.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  int _day = DateTime.now().weekday;
  String? _selectedFriendId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    final friendsAsync = ref.watch(
      StreamProvider<List<Friend>>((ref) => ref.watch(friendRepositoryProvider).watchFriends()),
    );
    final myClasses = ref.watch(myClassesProvider).value ?? [];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Free together', style: theme.textTheme.headlineMedium),
              Text('Pick friends and a day.', style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.l),

              // Friends Selection Chips
              friendsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => const SizedBox.shrink(),
                data: (friends) {
                  if (friends.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  _selectedFriendId ??= friends.first.friendId;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final f in friends) ...[
                          PillChip(
                            label: f.displayName,
                            selected: _selectedFriendId == f.friendId,
                            onTap: () => setState(() => _selectedFriendId = f.friendId),
                          ),
                          const SizedBox(width: AppSpacing.s),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.l),

              // Day Selector Chips
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

              // Mutual Free Time Output
              if (_selectedFriendId == null)
                const EmptyState(
                  title: 'No friends added',
                  message: 'Add friends in the Friends tab to find mutual free time.',
                )
              else
                Consumer(
                  builder: (context, ref, _) {
                    final busySlotsAsync = ref.watch(
                      StreamProvider<List<BusySlot>>((ref) =>
                          ref.watch(friendScheduleRepositoryProvider).watchBusySlots(_selectedFriendId!)),
                    );

                    return busySlotsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => EmptyState(
                        title: 'Couldn’t load friend schedule',
                        message: err.toString(),
                      ),
                      data: (friendSlots) {
                        final freeSlots = ref.watch(
                          mutualAvailabilityProvider((
                            myClasses: myClasses,
                            friendSlots: friendSlots,
                            day: _day,
                          )),
                        );

                        if (freeSlots.isEmpty) {
                          return const EmptyState(
                            title: 'No mutual free time',
                            message: 'Both of you are busy during standard school hours.',
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Everyone free', style: theme.textTheme.titleMedium),
                            const SizedBox(height: AppSpacing.m),
                            for (final slot in freeSlots) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.l),
                                margin: const EdgeInsets.only(bottom: AppSpacing.m),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  border: Border.all(color: appColors.line),
                                  borderRadius: BorderRadius.circular(AppRadius.card),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${formatMinutes(slot.startMinute)} – ${formatMinutes(slot.endMinute)}',
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          Text(
                                            '${(slot.endMinute - slot.startMinute) ~/ 60}h free window',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
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