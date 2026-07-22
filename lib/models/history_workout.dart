import 'package:rg_gym/models/training_exercise.dart';

class HistoryWorkout {
  final String id;
  final String name;
  final List<TrainingExercise>? trainingExercises;
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
              .map((e) => TrainingExercise.fromJson(e))
              .toList()
          : null,
      date: DateTime.parse(json['date']),
      restDuration: Duration(milliseconds: json['restDuration']),
      preparationDuration: Duration(milliseconds: json['preparationDuration']),
      executionDuration: Duration(milliseconds: json['executionDuration'])
    );
  }

  Duration get totalDuration => restDuration + executionDuration + preparationDuration;
}