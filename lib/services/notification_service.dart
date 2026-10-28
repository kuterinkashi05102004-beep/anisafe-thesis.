import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int warningNotificationId = 1001;
  static const int abnormalNotificationId = 1002;
  static const int disconnectedNotificationId = 1003;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initializationSettings);

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showWarningNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'anisafe_warning_channel',
      'AniSafe Warning Alerts',
      channelDescription:
          'Notifications for repeated Warning monitoring findings.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      warningNotificationId,
      'AniSafe Warning',
      'Warning condition detected after 3 consecutive Warning minutes.',
      details,
    );
  }

  Future<void> showAbnormalNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'anisafe_abnormal_channel',
      'AniSafe Critical Alerts',
      channelDescription:
          'Notifications for repeated critical monitoring findings.',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      abnormalNotificationId,
      'AniSafe Critical Alert',
      'Critical condition detected after 4 consecutive Abnormal minutes.',
      details,
    );
  }


  Future<void> showDisconnectedNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'anisafe_connection_channel',
      'AniSafe Connection Alerts',
      channelDescription:
          'Notifications when the ESP32 connection is lost.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      disconnectedNotificationId,
      'AniSafe: ESP32 Disconnected',
      'Monitoring has stopped. Reconnect the ESP32 and '
          'start a new monitoring session.',
      details,
    );
  }



  Future<void> cancelWarningNotification() async {
    await _notifications.cancel(warningNotificationId);
  }

  Future<void> cancelAbnormalNotification() async {
    await _notifications.cancel(abnormalNotificationId);
  }
}