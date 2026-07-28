import 'package:rg_gym/models/chart_data.dart';
import 'package:rg_gym/models/history_workout.dart';
import 'package:rg_gym/models/training_exercise.dart';
import 'package:rg_gym/screens/tabs/exercises/tabs/statistics_tab.dart';

class ExerciseRecords {
  final ChartData bestVolume;
  final ChartData bestWeight;
  final ChartData best1RM;
  final ChartData bestReps;

  const ExerciseRecords({
    required this.bestVolume,
    required this.bestWeight,
    required this.best1RM,
    required this.bestReps,
  });
}

extension ExerciseRecordsExtension on ExerciseRecords {
  ChartData get(StatisticType type) {
    switch (type) {
      case StatisticType.volume:
        return bestVolume;

      case StatisticType.weight:
        return bestWeight;

      case StatisticType.oneRm:
        return best1RM;

      case StatisticType.reps:
        return bestReps;
    }
  }
}

class StatisticsResult {
  final List<ChartData> points;
  final double average;
  final ExerciseRecords records;

  const StatisticsResult({
    required this.points,
    required this.average,
    required this.records,
  });

}

class StatisticsCalculator {
  static StatisticsResult calculate({
    required List<HistoryWorkout> history,
    required int exerciseId,
    required StatisticType type,
    required FilterDaysWithAll filter,
  }) {
    final filtered = _filterHistory(history, filter);

    final points = _buildPoints(filtered, exerciseId, type);

    final average = _average(points);

    final records = _buildRecords(history, exerciseId);

    return StatisticsResult(points: points, average: average, records: records);
  }

  static List<HistoryWorkout> _filterHistory(List<HistoryWorkout> history, FilterDaysWithAll filter) {
    if(filter == .all) return history;

    final days = switch(filter) {
      .all => 0,
      .seven => 7,
      .fourteen => 14,
      .twentyEight => 28,
      .ninety => 90
    };

    final minDate = DateTime.now().subtract(Duration(days: days));

    return history.where((e) => e.date.isAfter(minDate)).toList();
  }

  static List<ChartData> _buildPoints(List<HistoryWorkout> history, int exerciseId, StatisticType type) {
    final List<ChartData> points = [];
    final orderedHistory = [...history]..sort((a, b) => a.date.compareTo(b.date));

    for(final wourkout in orderedHistory) {
      final completed = wourkout.completedExercises.where((e) => e.exercise == exerciseId);

      if(completed.isEmpty) continue;

      double value = switch(type) {
        .volume => _calculateVolume(completed),
      .weight =>
          _calculateWeight(completed),
      .reps =>
          _calculateReps(completed),
      .oneRm =>
          _calculateOneRM(completed),
      };

      points.add(ChartData(date: wourkout.date, value: value));
    }

    return points;
  }

  static double _calculateVolume(Iterable<TrainingExercise> exercises) {
    double volume = 0;

    for(final exercise in exercises){
      for(final set in exercise.sets){
        volume += (set.weight ?? 0) * (set.reps ?? 0);
      }
    }

    return volume;
  }

  static double _calculateWeight(Iterable<TrainingExercise> exercises) {
    double maxWeight = 0;

    for(final exercise in exercises){
      for(final set in exercise.sets){
        if((set.weight ?? 0) > maxWeight){
          maxWeight = set.weight!;
        }
      }
    }

    return maxWeight;
  }

  static double _calculateReps(Iterable<TrainingExercise> exercises) {
    int reps = 0;

    for(final exercise in exercises){
      for(final set in exercise.sets){
        reps += set.reps ?? 0;
      }
    }

    return reps.toDouble();
  }

  static double _calculateOneRM(Iterable<TrainingExercise> exercises) {
    double best = 0;

    for(final exercise in exercises) {
      for(final set in exercise.sets) {
        final weight = set.weight ?? 0;
        final reps = set.reps ?? 0;
        
        if(weight == 0 || reps == 0) continue;

        final oneRM = weight * (1 + reps / 30);

        if(oneRM > best) best = oneRM;
      }
    }

    return best;
  }

  static double _average(List<ChartData> points) {
    if(points.isEmpty) return 0;

    return points.map((e) => e.value).reduce((a, b) => a + b) / points.length;
  }

  static ExerciseRecords _buildRecords(List<HistoryWorkout> history, int exerciseId) {
    ChartData bestVolume = ChartData(date: DateTime(1970), value: 0);

    ChartData bestWeight = ChartData(date: DateTime(1970), value: 0);

    ChartData best1RM = ChartData(date: DateTime(1970), value: 0);

    ChartData bestReps = ChartData(date: DateTime(1970), value: 0);

    for (final workout in history) {
      final exercises = workout.completedExercises.where((e) => e.exercise == exerciseId);

      if (exercises.isEmpty) continue;

      final volume = _calculateVolume(exercises);
      final weight = _calculateWeight(exercises);
      final reps = _calculateReps(exercises);
      final oneRM = _calculateOneRM(exercises);

      if (volume > bestVolume.value) {
        bestVolume = ChartData(date: workout.date, value: volume);
      }

      if (weight > bestWeight.value) {
        bestWeight = ChartData(date: workout.date, value: weight);
      }

      if (reps > bestReps.value) {
        bestReps = ChartData(date: workout.date, value: reps);
      }

      if (oneRM > best1RM.value) {
        best1RM = ChartData(date: workout.date, value: oneRM);
      }
    }

    return ExerciseRecords(
      bestVolume: bestVolume,
      bestWeight: bestWeight,
      best1RM: best1RM,
      bestReps: bestReps,
    );
  }
}