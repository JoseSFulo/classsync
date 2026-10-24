import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/schedule_format.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pill_chip.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/class_entry.dart';
import '../auth/auth_providers.dart';
import '../reminders/reminder_prompt.dart';
import 'class_block.dart';
import 'timetable_providers.dart';
import 'week_grid.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({this.initialDay, super.key});

  /// 1 (Monday) to 7 (Sunday). Defaults to today.
  final int? initialDay;

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  late int _day = widget.initialDay ?? DateTime.now().weekday;
  bool _showWeek = false;
  @override
  void initState() {
    super.initState();
    // Ask once the screen is on display, so the dialog has something behind it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(offerReminders(context, ref));
      }
    });
  }

  // The class form screen arrives on Day 3. For now it is a placeholder.
  void _addClass() => context.push(AppRoutes.classForm);

  void _editClass(ClassEntry entry) =>
      context.push(AppRoutes.editClass(entry.id));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final classes = ref.watch(myClassesProvider);
    final defaultMinutes =
        ref.watch(authStateProvider).value?.defaultReminderMinutes ?? 10;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addClass,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add class'),
      ),
      body: SafeArea(
        child: classes.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            title: 'Couldn’t load your classes',
            message: error is AppFailure ? error.message : 'Please try again.',
          ),
          data: (list) => _content(context, list, defaultMinutes),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    List<ClassEntry> classes,
    int defaultMinutes,
  ) {
    final theme = Theme.of(context);
    final today = classes.where((c) => c.days.contains(_day)).toList()
      ..sort((a, b) => a.startMinute.compareTo(b.startMinute));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        96, // keeps the last class clear of the Add class button
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _showWeek ? 'This week' : weekdayName(_day),
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              PillChip(
                label: 'Day',
                selected: !_showWeek,
                onTap: () => setState(() => _showWeek = false),
              ),
              const SizedBox(width: AppSpacing.s),
              PillChip(
                label: 'Week',
                selected: _showWeek,
                onTap: () => setState(() => _showWeek = true),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          if (classes.isEmpty)
            const EmptyState(
              title: 'Nothing here yet',
              message:
                  'Add your first class and I’ll remind you before it '
                  'starts.',
            )
          else if (_showWeek)
            WeekGrid(classes: classes, onTapClass: _editClass)
          else ...[
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
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
            const SizedBox(height: AppSpacing.l),
            if (today.isEmpty)
              EmptyState(
                title: 'Free day',
                message:
                    'No classes on ${weekdayName(_day)}. '
                    'Enjoy the slow day.',
              )
            else
              for (final c in today)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: ClassBlock(
                    entry: c,
                    defaultReminderMinutes: defaultMinutes,
                    onTap: () => _editClass(c),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
