import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/pill_chip.dart';
import '../auth/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text('This removes your account, classes, and friendships. It cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authRepositoryProvider).deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final repo = ref.watch(settingsRepositoryProvider);

    final currentReminder = user?.defaultReminderMinutes ?? 10;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(
                      user?.displayName.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.displayName ?? 'Student', style: theme.textTheme.titleMedium),
                        Text('Signed in with Google', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Default Reminder Picker
              Text('Default reminder', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  PillChip(
                    label: '10 min',
                    selected: currentReminder == 10,
                    onTap: () => repo.setDefaultReminderMinutes(10),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  PillChip(
                    label: '30 min',
                    selected: currentReminder == 30,
                    onTap: () => repo.setDefaultReminderMinutes(30),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  PillChip(
                    label: '1 hour',
                    selected: currentReminder == 60,
                    onTap: () => repo.setDefaultReminderMinutes(60),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Privacy Notice
              Text('Privacy', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Friends see busy or free time only by default. You can enable full class details per friend in the Friends tab.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Sign Out Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text('Sign out'),
              ),
              const SizedBox(height: AppSpacing.m),

              // Delete Account Button
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () => _confirmDeleteAccount(context, ref),
                child: const Text('Delete account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}