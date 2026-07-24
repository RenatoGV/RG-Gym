import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rg_gym/models/workout.dart';
import 'package:rg_gym/service/workout_foreground.dart';
import 'package:rg_gym/service/workout_notification.dart';
import 'package:rg_gym/service/workout_session_manager.dart';
import 'package:rg_gym/service/workout_session_storage.dart';

class WorkoutSessionProvider extends ChangeNotifier with WidgetsBindingObserver {
  WorkoutSessionManager? _session;

  WorkoutSessionManager? get session => _session;

  bool get hasSession => _session != null;

  bool _isAppInBackground = false;

  DateTime? _lastPersist;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInBackground = state == AppLifecycleState.paused || state == AppLifecycleState.inactive;

    if(state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      unawaited(_persist(force: true));
    }
  }

  WorkoutSessionProvider() {
    WidgetsBinding.instance.addObserver(this);
    WorkoutForeground.listenToEvents(_onForegroundEvent);
  }

  Future<void> restoreSession() async {
    if (_session != null) return;

    final runtimeInstance = WorkoutSessionManager.instance;

    if(runtimeInstance != null) {
      _attachSession(runtimeInstance);
      return;
    }

    final json = await WorkoutSessionStorage.get();
    if(json == null) return;

    try {
      final restored = WorkoutSessionManager.fromJson(
        json,
        onFinished: finishWorkout,
        onRestFinished: _onRestFinished,
        onCountdownBeep: _playCountdownBeep
      );

      if(restored.isFinished) {
        await WorkoutSessionStorage.clear();
        WorkoutSessionManager.clearInstance();
        return;
      }

      _attachSession(restored);

      await WorkoutForeground.start();
    } catch (_) {
      await WorkoutSessionStorage.clear();
      WorkoutSessionManager.clearInstance();
    }
  }

  void _attachSession(WorkoutSessionManager manager) {
    _session = manager;
    _session!.addListener(_onSessionChanged);
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

  Future<void> _playCountdownBeep () async {
    final player = AudioPlayer();

    await player.play(
      AssetSource('sounds/countdown.mp3')
    );
  }

  Future<void> startWorkout(Workout workout) async {
    _session?.dispose();

    final manager = WorkoutSessionManager(workout, onFinished: finishWorkout, onRestFinished: _onRestFinished, onCountdownBeep: _playCountdownBeep);

    _attachSession(manager);
    
    manager.start();

    notifyListeners();

    await Permission.ignoreBatteryOptimizations.request();

    await WorkoutForeground.start();

    await _persist(force: true);
  }

  Future<void> finishWorkout() async {
    final currentSession = _session;

    if (currentSession == null) return;

    await WorkoutForeground.stop();

    currentSession.removeListener(_onSessionChanged);

    WorkoutSessionManager.clearInstance();

    currentSession.dispose();

    _session = null;

    await WorkoutSessionStorage.clear();

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

    unawaited(_persist());

    notifyListeners();
  }

  Future<void> _persist({bool force = false}) async {
    final currentSession = _session;

    if(currentSession == null) return;

    final now = DateTime.now();

    if(!force && _lastPersist != null && now.difference(_lastPersist!) < const Duration(seconds: 3)) {
      return;
    }

    _lastPersist = now;

    await WorkoutSessionStorage.save(currentSession.toJson());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _session?.removeListener(_onSessionChanged);
    WorkoutSessionManager.clearInstance();
    _session?.dispose();
    super.dispose();
  }
}