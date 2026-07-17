import 'package:uuid/uuid.dart';

class TrainingExercise {
  final String id;
  final int exercise;
  TrainingType type;
  List<TrainingSet> sets;
  int restTime;
  String? note;

  TrainingExercise({
    required this.id,
    required this.exercise,
    this.type = TrainingType.repsWeight,
    List<TrainingSet>? sets,
    this.restTime = 60,
    this.note
  }) : sets = sets ?? [TrainingSet(reps: 0, weight: 0), TrainingSet(reps: 0, weight: 0), TrainingSet(reps: 0, weight: 0)];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise': exercise,
      'type': type.name,
      'sets': sets.map((e) => e.toJson()).toList(),
      'restTime': restTime,
      'note': note
    };
  }

  factory TrainingExercise.fromJson(Map<String, dynamic> json) {
    return TrainingExercise(
      id: json['id'],
      exercise: json['exercise'],
      type: TrainingType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => TrainingSet.fromJson(e))
          .toList(),
      restTime: json['restTime'],
      note: json['note']
    );
  }

  TrainingExercise copyWithNewId() {
    return TrainingExercise(
      id: const Uuid().v4(),
      exercise: exercise,
      type: type,
      sets: sets.map((e) => e.clone()).toList(),
      restTime: restTime,
      note: note
    );
  }

  TrainingExercise clone() {
    return TrainingExercise(id: id, exercise: exercise, type: type, sets: sets.map((e) => e.clone()).toList(), restTime: restTime, note: note);
  }
}

enum TrainingType {
  repsWeight,
  reps,
  weight,
  time
}

class TrainingSet {
  int? reps;
  double? weight;
  Duration? time;

  TrainingSet({
    this.reps,
    this.weight,
    this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'time': time?.inSeconds,
    };
  }

  factory TrainingSet.fromJson(Map<String, dynamic> json) {
    return TrainingSet(
      reps: json['reps'],
      weight: (json['weight'] as num?)?.toDouble(),
      time: json['time'] != null
          ? Duration(seconds: json['time'])
          : null,
    );
  }

  TrainingSet clone() {
    return TrainingSet(
      reps: reps,
      weight: weight,
      time: time
    );
  }
}