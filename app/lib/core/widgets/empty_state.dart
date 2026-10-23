import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    this.emoji = '🦥',
    super.key,
  });

  final String title;
  final String message;

  /// Stand-in for the mascot until the artwork is ready.
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.m),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
