import 'package:go_router/go_router.dart';

import '../widgets/placeholder_screen.dart';

/// Every screen address in the app, defined once.
abstract final class AppRoutes {
  static const signIn = '/sign-in';
  static const timetable = '/';
  static const classForm = '/class';
  static const friends = '/friends';
  static const availability = '/availability';
  static const settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.timetable,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, state) => const PlaceholderScreen(title: 'Sign in'),
    ),
    GoRoute(
      path: AppRoutes.timetable,
      builder: (context, state) => const PlaceholderScreen(title: 'Timetable'),
    ),
    GoRoute(
      path: AppRoutes.classForm,
      builder: (context, state) => const PlaceholderScreen(title: 'Class'),
    ),
    GoRoute(
      path: AppRoutes.friends,
      builder: (context, state) => const PlaceholderScreen(title: 'Friends'),
    ),
    GoRoute(
      path: AppRoutes.availability,
      builder: (context, state) =>
          const PlaceholderScreen(title: 'Shared availability'),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
    ),
  ],
);
