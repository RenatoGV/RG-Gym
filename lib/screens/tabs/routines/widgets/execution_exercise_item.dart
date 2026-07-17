import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/models/training_exercise.dart';

class ExecutionExerciseItem extends StatefulWidget {
  final int index;
  final TrainingExercise trainingExercise;
  final bool isCurrentExercise;
  final bool isCompleted;

  const ExecutionExerciseItem({
    super.key,
    required this.index,
    required this.trainingExercise,
    required this.isCurrentExercise,
    required this.isCompleted,
  });

  @override
  State<ExecutionExerciseItem> createState() => _ExecutionExerciseItemState();
}

class _ExecutionExerciseItemState extends State<ExecutionExerciseItem> {
  @override
  Widget build(BuildContext context) {
    Exercise exercise = exercises.firstWhere((e) => e.id == widget.trainingExercise.exercise);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                exercise.gif,
                fit: BoxFit.cover,
                opacity: widget.isCompleted ? AlwaysStoppedAnimation(0.5) : AlwaysStoppedAnimation(1),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exercise.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.isCompleted ? AppColors.text : widget.isCurrentExercise ? AppColors.primary : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: widget.isCompleted ? .lineThrough : .none
                  ),
                ),

                const SizedBox(height: 10),

                AutoSizeText(
                  maxLines: 1,
                  minFontSize: 12,
                  getTrainingSummary(widget.trainingExercise),
                  style: TextStyle(color: AppColors.text, decoration: widget.isCompleted ? .lineThrough : .none),
                ),
              ],
            ),
          ),
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
