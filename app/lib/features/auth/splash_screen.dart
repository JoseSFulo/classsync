import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stand-in until the mascot artwork is ready.
            const Text('🦥', style: TextStyle(fontSize: 96)),
            const SizedBox(height: AppSpacing.m),
            Text('ClassSync', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Syncing your schedule…\nSlow and steady. Almost there.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
