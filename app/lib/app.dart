import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/reminders/reminder_providers.dart';

class ClassSyncApp extends ConsumerStatefulWidget {
  const ClassSyncApp({super.key});

  @override
  ConsumerState<ClassSyncApp> createState() => _ClassSyncAppState();
}

class _ClassSyncAppState extends ConsumerState<ClassSyncApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(reminderAccessProvider);
      ref.invalidate(reminderSyncProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(reminderSyncProvider);
    return MaterialApp.router(
      title: 'ClassSync',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
