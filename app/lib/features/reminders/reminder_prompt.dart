import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'reminder_providers.dart';

/// Explains why reminders need permission, then asks for it.
///
/// Runs once per app session after sign-in. With [force], used by the button
/// on the Me screen, it runs even if the explanation was already shown.
Future<void> offerReminders(
  BuildContext context,
  WidgetRef ref, {
  bool force = false,
}) async {
  final offer = ref.read(reminderOfferProvider);
  if (offer.shown && !force) {
    return;
  }

  final scheduler = ref.read(reminderSchedulerProvider);
  if (await scheduler.isAllowed()) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  offer.shown = true;

  final agreed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Allow reminders?'),
      content: const Text(
        'ClassSync needs notification access to remind you before each '
        'class. You can change this later in your phone settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Not now'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Allow reminders'),
        ),
      ],
    ),
  );
  if (agreed != true || !context.mounted) {
    return;
  }

  final granted = await scheduler.requestPermission();
  if (!context.mounted) {
    return;
  }
  ref.invalidate(reminderAccessProvider);

  if (granted) {
    // Schedule right away instead of waiting for the next change.
    ref.invalidate(reminderSyncProvider);
    return;
  }

  // After two refusals Android stops showing its dialog, so point to settings.
  if (force) {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reminders are off'),
        content: const Text(
          'To turn them on, open your phone’s Settings, then Apps, then '
          'ClassSync, then Notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// A notice on the Me screen, shown only while reminders are blocked.
class ReminderAccessNotice extends ConsumerWidget {
  const ReminderAccessNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(reminderAccessProvider).value;
    if (allowed != false) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.l),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: context.appColors.soft,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reminders are off', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Turn them on to get a notification before each class.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.m),
          FilledButton(
            onPressed: () =>
                unawaited(offerReminders(context, ref, force: true)),
            child: const Text('Turn on reminders'),
          ),
        ],
      ),
    );
  }
}
