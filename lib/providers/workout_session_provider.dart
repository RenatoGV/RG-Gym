import 'package:flutter/material.dart';
import 'package:rg_gym/models/workout.dart';
import 'package:rg_gym/service/workout_foreground.dart';
import 'package:rg_gym/service/workout_notification.dart';
import 'package:rg_gym/service/workout_session_manager.dart';

class WorkoutSessionProvider extends ChangeNotifier with WidgetsBindingObserver {
  WorkoutSessionManager? _session;

  WorkoutSessionManager? get session => _session;

  bool get hasSession => _session != null;

  bool _isAppInBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInBackground = state == AppLifecycleState.paused || state == AppLifecycleState.inactive;
  }

  WorkoutSessionProvider() {
    WidgetsBinding.instance.addObserver(this);
    WorkoutForeground.listenToEvents(_onForegroundEvent);
  }

  void _onForegroundEvent(Object data) {
    if (data is Map<String, dynamic> && data['type'] == 'tick') {
      _session?.tick();
    }
  }

  void _onRestFinished() async {
    if (!_isAppInBackground) return;

    await WorkoutNotification.showRestFinishedNotification();
  }

  Future<void> startWorkout(Workout workout) async {
    _session?.dispose();

    _session = WorkoutSessionManager(workout, onFinished: finishWorkout, onRestFinished: _onRestFinished);
    _session!.addListener(_onSessionChanged);

    _session!.start();

    notifyListeners();

    await WorkoutForeground.start();
  }

  Future<void> finishWorkout() async {
    final currentSession = _session;

    if (currentSession == null) return;

    await WorkoutForeground.stop();

    currentSession.removeListener(_onSessionChanged);
    currentSession.dispose();

    _session = null;

    notifyListeners();
  }

  void _onSessionChanged() {
    final currentSession = _session;

    if(currentSession == null) return;

    final title = currentSession.notificationTitle;
    final text = currentSession.notificationText;

    WorkoutForeground.updateNotification(
      title: title,
      text: text
    );

    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _session?.removeListener(_onSessionChanged);
    _session?.dispose();
    super.dispose();
  }
}