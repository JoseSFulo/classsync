import 'package:flutter/material.dart';

import 'core/router/app_router.dart';

class ClassSyncApp extends StatelessWidget {
  const ClassSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'ClassSync', routerConfig: appRouter);
  }
}
