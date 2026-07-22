import 'package:rg_gym/models/training_exercise.dart';
import 'package:uuid/uuid.dart';

class Workout {
  final String id;
  final String name;
  final List<TrainingExercise>? trainingExercises;
  final List<String>? days;

  const Workout({
    required this.id,
    required this.name,
    this.trainingExercises,
    this.days
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trainingExercises': trainingExercises?.map((t) => t.toJson()).toList(),
      'days': days
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      trainingExercises: json['trainingExercises'] != null
          ? (json['trainingExercises'] as List)
              .map((e) => TrainingExercise.fromJson(e))
              .toList()
          : null,
      days: (json['days'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Workout copyWithNewId() {
    return Workout(
      id: const Uuid().v4(),
      name: name,
      trainingExercises: trainingExercises?.map((t) => t.copyWithNewId()).toList(),
      days: [...?days],
    );
  }
}

