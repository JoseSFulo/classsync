import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/schedule_format.dart';
import '../../domain/models/class_entry.dart';

class ClassBlock extends StatelessWidget {
  const ClassBlock({
    required this.entry,
    required this.defaultReminderMinutes,
    required this.onTap,
    super.key,
  });

  final ClassEntry entry;
  final int defaultReminderMinutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(entry.colorValue);
    final tint = Color.alphaBlend(
      color.withValues(alpha: 0.14),
      theme.colorScheme.surface,
    );
    final reminderAt =
        entry.startMinute - (entry.reminderMinutes ?? defaultReminderMinutes);
    final room = entry.room;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: Material(
        color: tint,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatMinutes(entry.startMinute)}–'
                          '${formatMinutes(entry.endMinute)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(entry.name, style: theme.textTheme.titleMedium),
                        Text(
                          room == null || room.isEmpty ? 'No room' : room,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Reminder ${formatMinutes(reminderAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
