import 'package:awesome_notifications/awesome_notifications.dart';

class WorkoutNotification {
  static const int restNotificationId = 2001;

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'workout_channel',
          channelName: 'Entrenamiento',
          channelDescription: 'Notificaciones del entrenamiento',
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/notification',
          enableVibration: true,
          criticalAlerts: true
        ),
      ],
    );
  }

  static Future<void> showRestFinishedNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: restNotificationId,
      channelKey: 'workout_channel',
      title: 'Descanso terminado',
      body: 'Es hora de continuar con el entrenamiento',
      category: NotificationCategory.Alarm,
      notificationLayout: NotificationLayout.Default,
      locked: true,
      autoDismissible: false,
      fullScreenIntent: true,
      displayOnForeground: false,
      displayOnBackground: true,
    ),
    actionButtons: [
        NotificationActionButton(
          key: 'CONTINUE_WORKOUT',
          label: 'Continuar',
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'ADD_15',
          label: '+ 15',
          actionType: .SilentAction
        )
      ],
    );
  }

  static Future<void> cancelRestFinishedNotification() async {
    await AwesomeNotifications().cancel(restNotificationId);
  }
}