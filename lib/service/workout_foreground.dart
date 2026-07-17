import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class WorkoutForeground {
  static const int serviceId = 1001;

  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'workout_foreground_service',
        channelName: 'Entrenamiento',
        channelDescription: 'Mantiene activo el entrenamiento mientras se ejecuta en segundo plano.',
        channelImportance: .LOW,
        priority: .LOW,
        onlyAlertOnce: true
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: true
      )
    );
  }

  static Future<void> start() async {
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    await FlutterForegroundTask.startService(
      serviceId: serviceId,
      notificationTitle: 'Entrenamiento activo',
      notificationText: 'Preparación',
      callback: startCallback,
    );
  }

  static Future<void> stop() async {
    if (!await FlutterForegroundTask.isRunningService) {
      return;
    }

    await FlutterForegroundTask.stopService();
  }

  static Future<void> updateNotification({required String title, required String text}) async {
    await FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: text,
    );
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(
    WorkoutTaskHandler(),
  );
}

class WorkoutTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(
    DateTime timestamp,
    TaskStarter starter,
  ) async {
    print('Workout foreground service iniciado');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    print('Tick: $timestamp');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool _) async {
    print('Workout foreground service detenido');
  }

  @override
  void onNotificationButtonPressed(String id) {
    print('Botón presionado: $id');
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  void onNotificationDismissed() {
    print('Notificación descartada');
  }
}