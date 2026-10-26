import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../logic/reminder_planner.dart';
import 'reminder_scheduler.dart';

class LocalNotificationScheduler implements ReminderScheduler {
  LocalNotificationScheduler([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  // Runs the plugin setup once, on first use.
  late final Future<void> _ready = _initialize();

  // Updates run one at a time, in the order they were requested.
  Future<void> _lastUpdate = Future<void>.value();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'class_reminders',
      'Class reminders',
      channelDescription: 'Reminders before your classes start',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<void> _initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> isAllowed() async {
    await _ready;
    final android = _android;
    // iOS permission handling is added with the iOS compile check.
    if (android == null) {
      return true;
    }
    return await android.areNotificationsEnabled() ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    await _ready;
    final android = _android;
    if (android == null) {
      return true;
    }
    return await android.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) {
    final run = _lastUpdate.then(
      (_) => _replace(reminders),
      onError: (_) => _replace(reminders),
    );
    _lastUpdate = run;
    return run;
  }

  Future<void> _replace(List<PlannedReminder> reminders) async {
    await _ready;
    await _plugin.cancelAllPendingNotifications();
    if (reminders.isEmpty) {
      return;
    }

    // Exact times when Android allows it, otherwise close to the time.
    final exact = await _android?.canScheduleExactNotifications() ?? true;
    final mode = exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (final reminder in reminders) {
      try {
        await _plugin.zonedSchedule(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          // An exact moment in time, so the phone's time zone doesn't matter.
          scheduledDate: tz.TZDateTime.from(reminder.at.toUtc(), tz.UTC),
          notificationDetails: _details,
          androidScheduleMode: mode,
        );
      } on ArgumentError {
        // The time passed while we were scheduling. Skip it.
      }
    }
  }
}
