import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/schedule_format.dart';
import '../../core/widgets/day_chips.dart';
import '../../core/widgets/empty_state.dart';
import '../friends/friends_providers.dart';
import 'availability_providers.dart';

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
    final friendsAsync = ref.watch(friendsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text('Free time', style: theme.textTheme.headlineMedium),
            ),
            friendsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading friends: $e')),
              data: (friends) {
                if (friends.isEmpty) {
                  return const Expanded(
                    child: EmptyState(
                      title: 'No friends yet',
                      message: 'Add friends to see when you are both free.',
                    ),
                  );
                }

                // Default to first friend if none selected
                _selectedFriendId ??= friends.first.friendId;

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Friend Selector
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            final isSelected =
                                friend.friendId == _selectedFriendId;
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.s,
                              ),
                              child: ChoiceChip(
                                label: Text(
                                  friend.displayName.split(' ').first,
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(
                                      () => _selectedFriendId = friend.friendId,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),

                      // Day Selector
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: DayChips(
                          isSelected: (d) => d == _day,
                          onTap: (d) => setState(() => _day = d),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Results List
                      Expanded(
                        child: _FreeTimeResults(
                          friendId: _selectedFriendId!,
                          day: _day,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeTimeResults extends ConsumerWidget {
  const _FreeTimeResults({required this.friendId, required this.day});

  final String friendId;
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final freeTimeAsync = ref.watch(
      mutualFreeTimeProvider((friendId: friendId, day: day)),
    );

    return freeTimeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(title: 'Error', message: e.toString()),
      data: (freeTimes) {
        if (freeTimes.isEmpty) {
          return EmptyState(
            title: 'No mutual free time',
            message:
                'Both of you are completely booked on ${weekdayName(day)}.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          itemCount: freeTimes.length,
          itemBuilder: (context, index) {
            final window = freeTimes[index];
            final durationMins = window.endMinute - window.startMinute;
            final hours = durationMins ~/ 60;
            final mins = durationMins % 60;

            String durationText = '';
            if (hours > 0) durationText += '$hours hr ';
            if (mins > 0) durationText += '$mins min';

            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.m),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              color: context.appColors.soft,
              elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppSpacing.m),
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                title: Text(
                  '${formatMinutes(window.startMinute)} – ${formatMinutes(window.endMinute)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('Free for ${durationText.trim()}'),
              ),
            );
          },
        );
      },
    );
  }
}
