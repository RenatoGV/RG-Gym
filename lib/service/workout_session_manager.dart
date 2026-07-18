import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/models/exercise.dart';
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
  final VoidCallback? onFinished;
  final VoidCallback? onRestFinished;

  WorkoutSessionManager(
    this.workout, {
      this.onFinished,
      this.onRestFinished
    }
  );

  late List<bool> completedExercises;

  DateTime? _workoutStart;
  DateTime? _pauseStart;

  Duration workoutDuration = Duration.zero;
  Duration phaseTime = Duration.zero;
  Duration preparationTime = const Duration(seconds: 15);

  int exerciseIndex = 0;
  int setIndex = 0;

  WorkoutPhase phase = WorkoutPhase.preparation;

  bool _restFinishedNotified = false;

  bool isPaused = false;

  bool get isFinished => phase == .finished;

  TrainingExercise get currentExercise => workout.trainingExercises![exerciseIndex];

  TrainingSet get currentSet => currentExercise.sets[setIndex];

  bool get isLastExercise => exerciseIndex == workout.trainingExercises!.length - 1;

  bool get isLastSet => setIndex == currentExercise.sets.length - 1;

  String get currentExerciseName {
    return currentExerciseData.name;
  }

  String get notificationTitle {
    switch (phase) {
      case WorkoutPhase.preparation:
        return 'Preparación • $remainingText';

      case WorkoutPhase.execution:
        return '$currentExerciseName • $remainingText';

      case WorkoutPhase.rest:
        return 'Descanso • $remainingText';

      case WorkoutPhase.finished:
        return 'Finalizado';
    }
  }

  String get notificationText {
    switch (phase) {
      case WorkoutPhase.preparation:
        return '$currentExerciseName • Próximo ejercicio';

      case WorkoutPhase.execution:
        return executionSummary;

      case WorkoutPhase.rest:
        return 'Siguiente: $currentExerciseName';

      case WorkoutPhase.finished:
        return 'Entrenamiento completado';
    }
  }

  String get remainingText {
    final seconds = phaseTime.inSeconds.remainder(60);

    if(phase == .finished) {
      return '00:00';
    }

    if(phase == .preparation) {
      return seconds.toString().padLeft(2, '0');
    }
    final minutes = phaseTime.inMinutes.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get executionSummary {
    final set = currentSet;

    switch (currentExercise.type) {
      case TrainingType.repsWeight:
        return 'Serie ${setIndex + 1}: ${set.reps} reps • ${set.weight} kg';

      case TrainingType.reps:
        return 'Serie ${setIndex + 1}: ${set.reps} repeticiones';

      case TrainingType.weight:
        return 'Serie ${setIndex + 1}: ${set.weight} kg';

      case TrainingType.time:
        return 'Serie ${setIndex + 1}: $remainingText';
    }
  }

  Exercise get currentExerciseData {
    return exercises.firstWhere(
      (e) => e.id == currentExercise.exercise,
    );
  }

  bool isExerciseCompleted(int index) => completedExercises[index];

  bool isNextExercise(TrainingExercise exercise) {
    final nextIndex = completedExercises.indexWhere(
      (completed) => !completed,
      exerciseIndex + 1,
    );

    int targetIndex = nextIndex;

    if (targetIndex == -1) {
      targetIndex = completedExercises.indexWhere(
        (completed) => !completed,
      );
    }

    if (targetIndex == -1) return false;

    return workout.trainingExercises![targetIndex].id == exercise.id;
  }

  void setExerciseCompleted(int index, bool value) {
    completedExercises[index] = value;

    if (index == exerciseIndex && value && phase != WorkoutPhase.finished) {
      _goToNextPendingExercise();
      return;
    }

    notifyListeners();
  }

  void tick() {
    if (isPaused || isFinished) return;

    switch (phase) {
      case WorkoutPhase.preparation:
      case WorkoutPhase.rest:
        _decreasePhaseTime();
        break;

      case WorkoutPhase.execution:
        _updateExecutionTime();
        break;

      case WorkoutPhase.finished:
        return;
    }

    notifyListeners();
  }

  void _decreasePhaseTime() {
    if (phaseTime <= Duration.zero) return;

    phaseTime -= const Duration(seconds: 1);

    if (phaseTime <= Duration.zero) {
      phaseTime = Duration.zero;

      if(phase == .rest && !_restFinishedNotified) {
        _restFinishedNotified = true;
        onRestFinished?.call();
      }
    }
  }

  void _updateExecutionTime() {
    if (currentExercise.type == TrainingType.time) {
      if (phaseTime > Duration.zero) {
        phaseTime -= const Duration(seconds: 1);
      }

      if (phaseTime < Duration.zero) {
        phaseTime = Duration.zero;
      }

      return;
    }

    phaseTime += const Duration(seconds: 1);
  }

  void start() {
    completedExercises = List.generate(
      workout.trainingExercises!.length,
      (_) => false
    );

    exerciseIndex = 0;
    setIndex = 0;

    workoutDuration = Duration.zero;
    phaseTime = Duration.zero;

    _workoutStart = DateTime.now();

    isPaused = false;
    
    _startPreparation();
  }

  void finish() {
    isPaused = false;

    phase = .finished;

    if(_workoutStart != null) {
      workoutDuration = DateTime.now().difference(_workoutStart!);
    }

    notifyListeners();
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
        Future.microtask(() {
          onFinished?.call();
        });
        // TODO: Guardar historial
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
      case .finished:
        _previousRest();
        break;
    }
  }

  void _startPreparation() {
    phase = WorkoutPhase.preparation;
    phaseTime = preparationTime;

    notifyListeners();
  }

  void _startExercise() {
    phase = .execution;

    if (currentExercise.type == TrainingType.time) {
      phaseTime = currentSet.time ?? Duration.zero;
    } else {
      phaseTime = Duration.zero;
    }

    notifyListeners();
  }

  
  void _startRest() {
    phase = .rest;
    _restFinishedNotified = false;
    phaseTime = Duration(seconds: currentExercise.restTime);

    notifyListeners();
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
    
    completedExercises[exerciseIndex] = true;

    _goToNextPendingExercise();
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

  void _goToNextPendingExercise() {
    final next = completedExercises.indexWhere((e) => !e, exerciseIndex + 1);

    if(next != -1) {
      exerciseIndex = next;
      setIndex = 0;
      _startPreparation();
      return;
    }

    final previous = completedExercises.indexWhere((e) => !e);

    if(previous != -1) {
      exerciseIndex = previous;
      setIndex = 0;
      _startPreparation();
      return;
    }

    finish();
  }

  void pause() {
    if (isPaused || isFinished) return;

    _pauseStart = DateTime.now();

    isPaused = true;

    notifyListeners();
  }

  void resume() {
    if (!isPaused || isFinished) return;

    if (_pauseStart != null && _workoutStart != null) {
      final pausedTime = DateTime.now().difference(_pauseStart!);

      _workoutStart = _workoutStart!.add(pausedTime);
    }

    _pauseStart = null;
    isPaused = false;

    notifyListeners();
  }
}