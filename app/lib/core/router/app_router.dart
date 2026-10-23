import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/app_shell.dart';

/// Every screen address in the app, defined once.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const timetable = '/';
  static const classForm = '/class';
  static const friends = '/friends';
  static const availability = '/availability';
  static const settings = '/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authStateProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final at = state.matchedLocation;

      if (auth.isLoading) {
        return at == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final signedIn = switch (auth) {
        AsyncData(:final value) => value != null,
        _ => false,
      };

      if (!signedIn) {
        return at == AppRoutes.signIn ? null : AppRoutes.signIn;
      }
      if (at == AppRoutes.signIn || at == AppRoutes.splash) {
        return AppRoutes.timetable;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.classForm,
        builder: (context, state) => const PlaceholderScreen(title: 'Class'),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.timetable,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Timetable screen'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.availability,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Free time screen'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.friends,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Friends screen'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Me screen'),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
