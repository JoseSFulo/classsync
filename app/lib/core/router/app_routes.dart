/// Every screen address in the app, defined once.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const timetable = '/';
  static const classForm = '/class';
  static String editClass(String id) =>
      '$classForm?id=${Uri.encodeQueryComponent(id)}';
  static const friendSchedule = '/friend/:id';

  static String friendScheduleFor(String id) =>
      '/friend/${Uri.encodeComponent(id)}';
  static const friends = '/friends';
  static const availability = '/availability';
  static const settings = '/settings';
}
