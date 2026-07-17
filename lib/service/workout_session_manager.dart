import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rg_gym/models/training_exercise.dart';
import 'package:rg_gym/models/workout.dart';

enum WorkoutPhase {
  preparation,
  execution,
  rest,
  finished
}

class WorkoutSessionManager extends ChangeNotifier {
  final Workout workout;

  WorkoutSessionManager(this.workout);

  Timer? _timer;

  DateTime? _workoutStart;
  DateTime? _pauseStart;

  Duration workoutDuration = Duration.zero;
  Duration phaseTime = Duration.zero;
  Duration preparationTime = const Duration(seconds: 15);

  int exerciseIndex = 0;
  int setIndex = 0;

  WorkoutPhase phase = WorkoutPhase.preparation;

  bool isPaused = false;

  bool get isFinished => phase == .finished;

  TrainingExercise get currentExercise => workout.trainingExercises![exerciseIndex];

  TrainingSet get currentSet => currentExercise.sets[setIndex];

  bool get isLastExercise => exerciseIndex == workout.trainingExercises!.length - 1;

  bool get isLastSet => setIndex == currentExercise.sets.length - 1;

  String get remainingText {
    final seconds = phaseTime.inSeconds.remainder(60);

    if(phase == .preparation) {
      return seconds.toString().padLeft(2, '0');
    }
    final minutes = phaseTime.inMinutes.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void start() {
    _timer?.cancel();

    exerciseIndex = 0;
    setIndex = 0;

    workoutDuration = Duration.zero;
    phaseTime = Duration.zero;

    _workoutStart = DateTime.now();

    isPaused = false;

    _startPreparation();
  }

  void finish() {
    _timer?.cancel();

    isPaused = false;
    phase = .finished;

    if(_workoutStart != null) {
      workoutDuration = DateTime.now().difference(_workoutStart!);
    }

    notifyListeners();
  }

  void _startPreparation() {
    phase = .preparation;
    notifyListeners();

    _startTimer(preparationTime);
  }

  void _startExercise() {
    phase = .execution;
    notifyListeners();

    if(currentExercise.type == .time) {
      _startTimer(currentSet.time!);
    } else {
      phaseTime = Duration.zero;
      _startStopwatch();
    }
  }

  void _startStopwatch({Duration from = Duration.zero}) {
    _timer?.cancel();

    phaseTime = from;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        phaseTime += const Duration(seconds: 1);
        notifyListeners();
      }
    );
  }

  void next() {
    isPaused = false;
    switch(phase) {
      case .preparation:
        _startExercise();
        break;
      case .execution:
        _afterExecution();
        break;
      case .rest:
        _afterRest();
        break;
      case .finished:
        break;
    }
  }

  void previous() {
    isPaused = false;
    switch(phase) {
      case .preparation:
        _previousPreparation();
        break;
      
      case .execution:
        _previousExecution();
        break;

      case .rest:
        _previousRest();
        break;

      case .finished:
        break;
    }
  }

  void _previousExecution() {
    if (setIndex > 0) {
      setIndex--;
      _startRest();
      return;
    }

    if (exerciseIndex > 0) {
      _startPreparation();
      return;
    }

    return;
  }

  void _previousPreparation() {
    if (exerciseIndex == 0) return;

    exerciseIndex--;
    setIndex = currentExercise.sets.length - 1;

    _startRest();
  }

  void _previousRest() {
    _startExercise();
  }

  void _afterExecution() {
    if(currentExercise.restTime > 0) {
      _startRest();
    } else {
      _afterRest();
    }
  }

  void _afterRest() {
    if(!isLastSet) {
      setIndex++;
      _startExercise();
      return;
    }

    if(!isLastExercise) {
      exerciseIndex++;
      setIndex = 0;
      _startPreparation();
      return;
    }

    finish();
  }

  void _startRest() {
    phase = .rest;
    notifyListeners();

    _startTimer(Duration(seconds: currentExercise.restTime));
  }

  void _startTimer(Duration duration) {
    _timer?.cancel();

    phaseTime = duration;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (phaseTime > Duration.zero) {
          phaseTime -= const Duration(seconds: 1);
        }

        if (phaseTime < Duration.zero) {
          phaseTime = Duration.zero;
        }

        notifyListeners();
      }
    );
  }

  void pause() {
    if(_timer == null || isPaused) return;

    _pauseStart = DateTime.now();

    _timer?.cancel();
    _timer = null;

    isPaused = true;

    notifyListeners();
  }

  void resume() {
    if(!isPaused) return;

    if (_pauseStart != null && _workoutStart != null) {
      final pausedTime = DateTime.now().difference(_pauseStart!);
      _workoutStart = _workoutStart!.add(pausedTime);
    }
    
    isPaused = false;

    notifyListeners();
    
    switch(phase) {
      case .preparation:
      case .rest:
        _startTimer(phaseTime);
        break;

      case .execution:
        if(currentExercise.type == .time) {
          _startTimer(phaseTime);
        } else {
          _startStopwatch(from: phaseTime);
        }
        break;
      
      case .finished:
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}