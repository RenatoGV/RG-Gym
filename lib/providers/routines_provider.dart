import 'package:flutter/foundation.dart';
import 'package:rg_gym/models/routine.dart';
import 'package:rg_gym/models/training_exercise.dart';
import 'package:rg_gym/models/workout.dart';
import 'package:rg_gym/service/routine_storage.dart';
import 'package:uuid/uuid.dart';

class RoutinesProvider extends ChangeNotifier {
  List<Routine> _routines = [];

  List<Routine> get routines => List.unmodifiable(_routines);

  Future<void> importRoutines(List<Routine> routines) async {
    _routines = routines;

    notifyListeners();
    await save();
  }

  Future<void> load() async {
    _routines = await RoutineStorage.getAll();
    notifyListeners();
  }

  Future<void> save() async {
    await RoutineStorage.saveAll(_routines);
  }

  Routine getById(String id) {
    return _routines.firstWhere((e) => e.id == id);
  }

  Future<void> add(Routine routine) async {
    _routines.add(routine);
    notifyListeners();
    await save();
  }

  Future<void> duplicate(Routine routine) async {
    final index = _routines.indexWhere((r) => r.id == routine.id);
    if(index == -1) return;

    final duplicated = routine.copyWithNewId();

    _routines.insert(index + 1, duplicated);

    notifyListeners();
    await save();
  }

  Future<void> update(Routine routine) async {
    final index = _routines.indexWhere((r) => r.id == routine.id);

    if(index == -1) throw Exception('Routine not found');

    _routines[index] = routine;

    notifyListeners();
    await save();
  }

  Future<void> remove(String id) async {
    _routines.removeWhere((e) => e.id == id);
    notifyListeners();
    await save();
  }

  Workout getWorkoutById(String routineId, String workoutId) {
    final routine = getById(routineId);

    return routine.workouts!.firstWhere((workout) => workout.id == workoutId);
  }

  Future<void> addWorkout(String routineId, Workout workout) async {
    final routine = getById(routineId);
    
    final updatedRoutine = Routine(
      id: routine.id,
      name: routine.name,
      comment: routine.comment,
      workouts: [
        ...?routine.workouts,
        workout
      ]
    );

    await update(updatedRoutine);
  }

  Future<void> duplicateWorkout(String routineId, Workout workout) async {
    final routine = getById(routineId);

    final workouts = [...?routine.workouts];

    final index = workouts.indexWhere((w) => w.id == workout.id);
    if(index == -1) return;

    final duplicated = workout.copyWithNewId();

    workouts.insert(index + 1, duplicated);

    Routine updatedRoutine = Routine(
      id: routine.id,
      name: routine.name,
      comment: routine.comment,
      workouts: workouts
    );

    await update(updatedRoutine);
  }

  Future<void> updateWorkout(String routineId, Workout workout) async {
    final routine = getById(routineId);
    final workouts = List<Workout>.from(routine.workouts ?? []);

    final index = workouts.indexWhere((w) => w.id == workout.id);

    if (index == -1) throw Exception('Workout not found');

    workouts[index] = workout;
    
    final updatedRoutine = Routine(
      id: routine.id,
      name: routine.name,
      comment: routine.comment,
      workouts: workouts
    );

    await update(updatedRoutine);
  }

  Future<void> removeWorkout(String routineId, String workoutId) async {
    final routine = getById(routineId);
    final workouts = List<Workout>.from(routine.workouts ?? [])
      ..removeWhere((w) => w.id == workoutId);

    final updatedRoutine = Routine(
      id: routine.id,
      name: routine.name,
      comment: routine.comment,
      workouts: workouts
    );
    
    await update(updatedRoutine);
  }

  TrainingExercise getTrainingExerciseById(String routineId, String workoutId, String trainingExerciseId) {
    final workout = getWorkoutById(routineId, workoutId);

    return workout.trainingExercises!.firstWhere((t) => t.id == trainingExerciseId);
  }

  Future<void> addTrainingExercises(String routineId, Workout workout, List<int> selectedExercises) async {
    final updatedWorkout = Workout(
      id: workout.id,
      name: workout.name,
      days: workout.days,
      trainingExercises: [
        ...?workout.trainingExercises,
        ...selectedExercises.map(
          (id) => TrainingExercise(
            id: const Uuid().v4(),
            exercise: id
          ),
        ),
      ],
    );

    await updateWorkout(routineId, updatedWorkout);
  }

  Future<void> addTrainingExercise(String routineId, String workoutId, TrainingExercise trainingExercise) async {
    Workout workout = getWorkoutById(routineId, workoutId);
    
    final updatedWorkout = Workout(
      id: workout.id,
      name: workout.name,
      days: workout.days,
      trainingExercises: [
        ...?workout.trainingExercises,
        trainingExercise
      ]
    );

    await updateWorkout(routineId, updatedWorkout);
  }

  Future<void> duplicateTrainingExercise(String routineId, String workoutId, TrainingExercise trainingExercise) async {
    final workout = getWorkoutById(routineId, workoutId);

    final trainingExercises = [...?workout.trainingExercises];

    final index = trainingExercises.indexWhere((t) => t.id == trainingExercise.id);
    if(index == -1) return;

    final duplicated = trainingExercise.copyWithNewId();

    trainingExercises.insert(index + 1, duplicated);

    Workout updatedWorkout = Workout(
      id: workout.id,
      name: workout.name,
      days: workout.days,
      trainingExercises: trainingExercises
    );

    await updateWorkout(routineId, updatedWorkout);
  }

  Future<void> removeTrainingExercise(String routineId, String workoutId, String trainingExerciseId) async {
    Workout workout = getWorkoutById(routineId, workoutId);

    final trainingExercises = List<TrainingExercise>.from(workout.trainingExercises ?? [])
      ..removeWhere((t) => t.id == trainingExerciseId);

    final updatedWorkout = Workout(
      id: workout.id,
      name: workout.name,
      days: workout.days,
      trainingExercises: trainingExercises
    );

    await updateWorkout(routineId, updatedWorkout);
  }

  Future<void> reorderTrainingExercises(String routineId, String workoutId, int oldIndex, int newIndex) async {
    final workout = getWorkoutById(routineId, workoutId);

    final trainingExercises = workout.trainingExercises!;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = trainingExercises.removeAt(oldIndex);

    trainingExercises.insert(newIndex, item);

    notifyListeners();

    await save();
  }

  Future<void> updateTrainingExercise(String routineId, String workoutId, TrainingExercise trainingExercise) async {
    final workout = getWorkoutById(routineId, workoutId);
    final trainingExercises = List<TrainingExercise>.from(workout.trainingExercises ?? []);

    final index = trainingExercises.indexWhere((t) => t.id == trainingExercise.id);

    if (index == -1) throw Exception('TrainingExercise not found');

    trainingExercises[index] = trainingExercise;

    Workout updatedWorkout = Workout(
      id: workout.id,
      name: workout.name,
      days: workout.days,
      trainingExercises: trainingExercises
    );

    await updateWorkout(routineId, updatedWorkout);
  }
}