import 'package:flutter/material.dart';
import 'package:rg_gym/models/workout.dart';
import 'package:rg_gym/service/workout_session_manager.dart';

class WorkoutSessionProvider extends ChangeNotifier {
  WorkoutSessionManager? _session;

  WorkoutSessionManager? get session => _session;

  bool get hasSession => _session != null;

  void startWorkout(Workout workout) {
    _session?.dispose();

    _session = WorkoutSessionManager(workout);
    
    _session!.addListener(_onSessionChanged);

    _session!.start();

    notifyListeners();
  }

  void finishWorkout() {
    if (_session == null) return;

    _session!.removeListener(_onSessionChanged);
    _session!.dispose();
    _session = null;
  }

  void _onSessionChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _session?.removeListener(_onSessionChanged);
    _session?.dispose();
    super.dispose();
  }
}