import 'dart:convert';

import 'package:rg_gym/models/routine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineStorage {
  static const _key = 'routines';

  static Future<List<Routine>> getAll() async {
    final sp = await SharedPreferences.getInstance();
    final data = sp.getStringList(_key) ?? [];

    return data
        .map((routine) => Routine.fromJson(jsonDecode(routine)))
        .toList();
  }

  static Future<void> saveAll(List<Routine> routines) async {
    final sp = await SharedPreferences.getInstance();
    final data = routines.map((r) => jsonEncode(r.toJson())).toList();

    await sp.setStringList(_key, data);
  }

  // static Future<Routine> get(String routineId) async {
  //   final sp = await SharedPreferences.getInstance();
  //   final data = sp.getStringList(_key) ?? [];
    
  //   return data.map((e) => Routine.fromJson(jsonDecode(e)))
  //           .firstWhere((routine) => routine.id == routineId);
  // }

  // static Future<void> save(Routine routine) async {
  //   final sp = await SharedPreferences.getInstance();
  //   final data = sp.getStringList(_key) ?? [];
    
  //   data.add(jsonEncode(routine.toJson()));

  //   await sp.setStringList(_key, data);
  // }

  // static Future<void> update(Routine routine) async {
  //   final sp = await SharedPreferences.getInstance();
  //   final data = sp.getStringList(_key) ?? [];
    
  //   final index = data.indexWhere((e) {
  //     final json = jsonDecode(e);
  //     return json['id'] == routine.id;
  //   });

  //   if(index == -1) throw Exception('Routine not found');

  //   data[index] = jsonEncode(routine.toJson());

  //   await sp.setStringList(_key, data);
  // }

  // static Future<void> delete(String routineId) async {
  //   final sp = await SharedPreferences.getInstance();
  //   final data = sp.getStringList(_key) ?? [];
    
  //   final index = data.indexWhere((e) {
  //     final json = jsonDecode(e);
  //     return json['id'] == routineId;
  //   });

  //   if(index == -1) throw Exception('Routine not found');

  //   data.removeAt(index);
    
  //   await sp.setStringList(_key, data);
  // }

  // static Future<Workout> getWorkout(String routineId, String workoutId) async {
  //   final routine = await get(routineId);

  //   return routine.workouts!.firstWhere((workout) => workout.id == workoutId);
  // }

  // static Future<void> addWorkout(String routineId, Workout workout) async {
  //   final routine = await get(routineId);
    
  //   final updatedRoutine = Routine(
  //     id: routine.id,
  //     name: routine.name,
  //     comment: routine.comment,
  //     workouts: [
  //       ...?routine.workouts,
  //       workout
  //     ]
  //   );

  //   await update(updatedRoutine);
  // }

  // static Future<void> updateWorkout(String routineId, Workout workout) async {
  //   final routine = await get(routineId);
  //   final workouts = List<Workout>.from(routine.workouts ?? []);
  //   final index = workouts.indexWhere((w) => w.id == workout.id);

  //   if (index == -1) {
  //     throw Exception('Workout not found');
  //   }

  //   workouts[index] = workout;
    
  //   final updatedRoutine = Routine(
  //     id: routine.id,
  //     name: routine.name,
  //     comment: routine.comment,
  //     workouts: workouts
  //   );

  //   await update(updatedRoutine);
  // }

  // static Future<void> deleteWorkout(String routineId, String workoutId) async {
  //   final routine = await get(routineId);
  //   final workouts = List<Workout>.from(routine.workouts ?? [])
  //     ..removeWhere((w) => w.id == workoutId);

  //   final updatedRoutine = Routine(
  //     id: routine.id,
  //     name: routine.name,
  //     comment: routine.comment,
  //     workouts: workouts
  //   );
    
  //   await update(updatedRoutine);
  // }

  // static Future<void> addTrainingExercises(String routineId, Workout workout, List<int> selectedExercises) async {
  //   final updatedWorkout = Workout(
  //     id: workout.id,
  //     name: workout.name,
  //     days: workout.days,
  //     trainingExercises: [
  //       ...?workout.trainingExercises,
  //       ...selectedExercises.map(
  //         (id) => TrainingExercise(
  //           id: const Uuid().v4(),
  //           exercise: id,
  //           type: TrainingType.repsWeight,
  //           sets: const [TrainingSet(reps: 10, weight: 10)],
  //         ),
  //       ),
  //     ],
  //   );

  //   await updateWorkout(routineId, updatedWorkout);
  // }
}