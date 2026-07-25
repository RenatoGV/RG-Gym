import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/models/muscle_group.dart';
import 'package:rg_gym/models/training_exercise.dart';

class HistoryTrainingExercise {
  final TrainingExercise trainingExercise;
  bool completed;

  HistoryTrainingExercise({
    required this.trainingExercise,
    required this.completed
  });

  Map<String, dynamic> toJson() {
    return {
      'trainingExercise': trainingExercise.toJson(),
      'completed': completed
    };
  }

  factory HistoryTrainingExercise.fromJson(Map<String, dynamic> json) {
    return HistoryTrainingExercise(
      trainingExercise: TrainingExercise.fromJson(json['trainingExercise']),
      completed: json['completed']
    );
  }
}

class HistoryWorkout {
  final String id;
  final String name;
  final List<HistoryTrainingExercise>? trainingExercises;
  final DateTime date;
  final Duration restDuration;
  final Duration preparationDuration;
  final Duration executionDuration;

  const HistoryWorkout({
    required this.id,
    required this.name,
    required this.trainingExercises,
    required this.date,
    required this.restDuration,
    required this.preparationDuration,
    required this.executionDuration
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trainingExercises': trainingExercises?.map((t) => t.toJson()).toList(),
      'date': date.toIso8601String(),
      'restDuration': restDuration.inMilliseconds,
      'preparationDuration': preparationDuration.inMilliseconds,
      'executionDuration': executionDuration.inMilliseconds
    };
  }

  factory HistoryWorkout.fromJson(Map<String, dynamic> json) {
    return HistoryWorkout(
      id: json['id'],
      name: json['name'],
      trainingExercises: json['trainingExercises'] != null
          ? (json['trainingExercises'] as List)
              .map((e) => HistoryTrainingExercise.fromJson(e))
              .toList()
          : null,
      date: DateTime.parse(json['date']),
      restDuration: Duration(milliseconds: json['restDuration']),
      preparationDuration: Duration(milliseconds: json['preparationDuration']),
      executionDuration: Duration(milliseconds: json['executionDuration'])
    );
  }

  Duration get totalDuration => restDuration + executionDuration + preparationDuration;

  List<TrainingExercise> get completedExercises => trainingExercises!.where((e) => e.completed).map((e) => e.trainingExercise).toList();

  String get musclesWorkedString => musclesWorked.map((m) => m.name).join(', ');

  Set<MuscleGroup> get musclesWorked => completedExercises
    .expand((t) {
      final exercise = exercises.firstWhere((e) => e.id == t.exercise);

      return [
        ...exercise.primaryMuscles,
        ...exercise.secondaryMuscles,
      ];
    }).map((id) => muscleGroups.firstWhere((m) => m.id == id))
    .toSet();
  
  int get completedSets => completedExercises.fold(0, (sum, e) => sum + e.sets.length);

  int get completedReps => completedExercises.fold(0, (sum, e) => sum + e.sets.fold(0, (setSum, s) => setSum + (s.reps ?? 0)));

  double get totalWeight => completedExercises.fold(0.0, (sum, e) => sum + e.sets.fold(0.0, (setSum, s) => setSum + (s.weight ?? 0)));

  List<MapEntry<String, double>> get muscleFatigue {
    final fatigue = <String, double>{};

    for (final t in completedExercises) {
      final exercise = exercises.firstWhere(
        (e) => e.id == t.exercise,
      );

      void addMuscles(List<int> muscles, double amount) {
        for (final muscleId in muscles) {
          final muscleName = muscleGroups.firstWhere((m) => m.id == muscleId).name;

          fatigue.update(
            muscleName,
            (value) => (value + amount).clamp(0.0, 1.0),
            ifAbsent: () => amount,
          );
        }
      }

      addMuscles(exercise.primaryMuscles, 0.3);
      addMuscles(exercise.secondaryMuscles, 0.1);
    }

    return fatigue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }
}