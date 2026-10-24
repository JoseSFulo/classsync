import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/pill_chip.dart';
import '../../domain/failures/app_failure.dart';
import '../auth/auth_providers.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  static const _reminderOptions = [10, 30, 60];

  String _label(int minutes) => minutes == 60 ? '1 hour' : '$minutes min';

  Future<void> _setDefaultReminder(
    BuildContext context,
    WidgetRef ref,
    int minutes,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(settingsRepositoryProvider)
          .setDefaultReminderMinutes(minutes);
    } on AppFailure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Couldn’t save. Please try again.')),
      );
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      // The router sends us back to the sign-in screen on its own.
      await ref.read(authRepositoryProvider).signOut();
    } on AppFailure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Couldn’t sign out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(authStateProvider).value;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = profile.displayName.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: context.appColors.soft,
                    child: Text(
                      initial,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: theme.textTheme.titleMedium),
                        Text(
                          'Signed in with Google',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Default reminder', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  for (final minutes in _reminderOptions)
                    PillChip(
                      label: _label(minutes),
                      selected: profile.defaultReminderMinutes == minutes,
                      onTap: () => _setDefaultReminder(context, ref, minutes),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Used for every new class. Reminders are notifications, so '
                'silent mode, Do Not Disturb, or battery saver can mute or '
                'delay them.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Privacy', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Friends see busy or free only. Turn on class names per '
                'friend in Friends.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xxl),
              OutlinedButton(
                onPressed: () => _signOut(context, ref),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
