import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/schedule_format.dart';
import '../../core/widgets/day_chips.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pill_chip.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/class_entry.dart';
import 'friend_schedule_providers.dart';
import 'friends_providers.dart';

class FriendScheduleScreen extends ConsumerStatefulWidget {
  const FriendScheduleScreen({
    required this.friendId,
    this.initialDay,
    super.key,
  });

  final String friendId;

  /// 1 (Monday) to 7 (Sunday). Defaults to today.
  final int? initialDay;

  @override
  ConsumerState<FriendScheduleScreen> createState() =>
      _FriendScheduleScreenState();
}

class _FriendScheduleScreenState extends ConsumerState<FriendScheduleScreen> {
  late int _day = widget.initialDay ?? DateTime.now().weekday;

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.friends);
    }
  }

  String _room(ClassEntry c) {
    final room = c.room;
    return room == null || room.isEmpty ? 'No room' : room;
  }

  Widget _entries(FriendSchedule schedule) {
    final cards = <Widget>[];
    switch (schedule) {
      case FullSchedule(:final classes):
        final today = classes.where((c) => c.days.contains(_day)).toList()
          ..sort((a, b) => a.startMinute.compareTo(b.startMinute));
        for (final c in today) {
          cards.add(
            _EntryCard(
              start: c.startMinute,
              end: c.endMinute,
              title: c.name,
              detail: _room(c),
              color: Color(c.colorValue),
            ),
          );
        }
      case BusySchedule(:final slots):
        final today = slots.where((s) => s.day == _day).toList()
          ..sort((a, b) => a.startMinute.compareTo(b.startMinute));
        for (final s in today) {
          cards.add(
            _EntryCard(
              start: s.startMinute,
              end: s.endMinute,
              title: 'Busy',
              detail: 'Details are private',
            ),
          );
        }
    }

    if (cards.isEmpty) {
      return EmptyState(
        title: 'Free all day',
        message: 'Nothing scheduled on ${weekdayName(_day)}.',
      );
    }
    return Column(children: cards);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name =
        ref
            .watch(friendsProvider)
            .value
            ?.where((f) => f.friendId == widget.friendId)
            .firstOrNull
            ?.displayName ??
        'Friend';
    final schedule = ref.watch(friendScheduleProvider(widget.friendId));

    final subtitle = switch (schedule.value) {
      FullSchedule() => 'Shares full timetable with you.',
      BusySchedule() => 'Shares busy and free times only.',
      null => '',
    };

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PillChip(
                label: '‹ Back',
                semanticLabel: 'Back',
                selected: false,
                onTap: _back,
              ),
              const SizedBox(height: AppSpacing.l),
              Text(name, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.l),
              DayChips(
                isSelected: (d) => d == _day,
                onTap: (d) => setState(() => _day = d),
              ),
              const SizedBox(height: AppSpacing.l),
              schedule.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.l),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => EmptyState(
                  title: 'Couldn’t load this schedule',
                  message: error is AppFailure
                      ? error.message
                      : 'Please try again.',
                ),
                data: _entries,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.start,
    required this.end,
    required this.title,
    required this.detail,
    this.color,
  });

  final int start;
  final int end;
  final String title;
  final String detail;

  /// Null for busy blocks, which carry no class information.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? context.appColors.muted;
    final tint = Color.alphaBlend(
      accent.withValues(alpha: 0.14),
      theme.colorScheme.surface,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          color: tint,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatMinutes(start)}–${formatMinutes(end)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(title, style: theme.textTheme.titleMedium),
                        Text(detail, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
