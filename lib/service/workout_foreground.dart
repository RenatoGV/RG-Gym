import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class WorkoutForeground {
  static const int serviceId = 1001;

  static Future<void> requestPermissions() async {
    final permission = await FlutterForegroundTask.checkNotificationPermission();

    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  static void listenToEvents(void Function(Object data) onData) {
    FlutterForegroundTask.addTaskDataCallback(onData);
  }

  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'workout_foreground_service',
        channelName: 'Entrenamiento',
        channelDescription: 'Mantiene activo el entrenamiento mientras se ejecuta en segundo plano.',
        channelImportance: .HIGH,
        priority: .HIGH,
        onlyAlertOnce: true,
        showWhen: true
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
      )
    );
  }

  static Future<void> start() async {
    if (await FlutterForegroundTask.isRunningService) return;

    await FlutterForegroundTask.startService(
      serviceId: serviceId,
      notificationTitle: 'Iniciando entrenamiento',
      notificationText: 'Preparación...',
      callback: startCallback,
    );
  }

  static Future<void> stop() async {
    if (!await FlutterForegroundTask.isRunningService) return;

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
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    FlutterForegroundTask.sendDataToMain({
      'type': 'tick',
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  void onNotificationDismissed() {}
}