import 'package:rg_gym/models/workout.dart';
import 'package:uuid/uuid.dart';

class Routine {
  final String id;
  final String name;
  final String? comment;
  final List<Workout>? workouts;

  const Routine({
    required this.id,
    required this.name,
    this.comment,
    this.workouts
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'comment': comment,
      'workouts': workouts?.map((workout) => workout.toJson()).toList(),
    };
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      comment: json['comment'],
      workouts: json['workouts'] != null
          ? (json['workouts'] as List)
              .map((e) => Workout.fromJson(e))
              .toList()
          : null,
    );
  }

  Routine copyWithNewId() {
    return Routine(
      id: const Uuid().v4(),
      name: name,
      comment: comment,
      workouts: workouts?.map((w) => w.copyWithNewId()).toList()
    );
  }
}