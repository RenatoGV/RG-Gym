import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/history_workout.dart';
import 'package:rg_gym/models/training_exercise.dart';

class HistoryExerciseItem extends StatelessWidget {
  final HistoryTrainingExercise historyExercise;

  const HistoryExerciseItem({
    super.key,
    required this.historyExercise
  });

  @override
  Widget build(BuildContext context) {
    final exercise = exercises.firstWhere((e) => e.id == historyExercise.trainingExercise.exercise);

    return Container(
      width: double.infinity,
      padding: .symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: AppColors.backgroundSecondary),
        borderRadius: BorderRadius.circular(7)
      ),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset(
                exercise.gif,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  exercise.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 10),

                AutoSizeText(
                  maxLines: 1,
                  minFontSize: 12,
                  getTrainingSummary(historyExercise.trainingExercise),
                  style: TextStyle(color: AppColors.text),
                )
              ],
            )
          ),
          Column(
            children: [
              Icon(
                historyExercise.completed ? Icons.check_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                color: historyExercise.completed ? Colors.green : AppColors.primary,
              )
            ],
          )
        ],
      )
    );
  }
}

String getTrainingSummary(TrainingExercise trainingExercise) {
  var repsText = '';
  var weightText = '';

  final series = trainingExercise.sets.length;
  final reps = trainingExercise.sets
    .map((s) => s.reps)
    .whereType<int>()
    .toList();

  if(reps.isNotEmpty) {
    final minReps = reps.reduce((a, b) => a < b ? a : b);
    final maxReps = reps.reduce((a, b) => a > b ? a : b);
    repsText = (minReps == maxReps) ? minReps.toString() : '$minReps - $maxReps';
  }

  final weights = trainingExercise.sets
    .map((s) => s.weight)
    .whereType<double>()
    .toList();

  if(weights.isNotEmpty) {
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    weightText = (minWeight == maxWeight) ? FormatHelper.formatDouble(minWeight).toString() : '${FormatHelper.formatDouble(minWeight)} - ${FormatHelper.formatDouble(maxWeight)}';
  }

  final totalMinutes = trainingExercise.sets
    .map((s) => s.time?.inMinutes ?? 0)
    .fold(0, (total, minutes) => total + minutes);

  switch(trainingExercise.type) {
    case .repsWeight:
      return "$series series • $repsText reps • $weightText kg";

    case TrainingType.reps:
      final reps = trainingExercise.sets.first.reps ?? 0;
      return "$series series • $reps reps";

    case TrainingType.weight:
      final weight = trainingExercise.sets.first.weight ?? 0;
      return "$series series • $weight kg";

    case TrainingType.time:
      return "$series series • $totalMinutes min";
  }
}
