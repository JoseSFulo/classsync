import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/friends/friends_screen.dart';
import '../../features/friends/friend_schedule_screen.dart';
import '../../features/settings/me_screen.dart';
import '../../features/timetable/class_form_screen.dart';
import '../../features/timetable/timetable_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/placeholder_screen.dart';
import 'app_routes.dart';

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
        builder: (context, state) =>
            ClassFormScreen(classId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.friendSchedule,
        builder: (context, state) =>
            FriendScheduleScreen(friendId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.timetable,
                builder: (context, state) => const TimetableScreen(),
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
                builder: (context, state) => const FriendsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const MeScreen(),
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
