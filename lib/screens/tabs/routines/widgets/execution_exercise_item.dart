import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/models/training_exercise.dart';
import 'package:rg_gym/providers/workout_session_provider.dart';

class ExecutionExerciseItem extends StatefulWidget {
  final int index;
  final TrainingExercise trainingExercise;
  final bool isNextExercise;

  const ExecutionExerciseItem({
    super.key,
    required this.index,
    required this.trainingExercise,
    required this.isNextExercise,
  });

  @override
  State<ExecutionExerciseItem> createState() => _ExecutionExerciseItemState();
}

class _ExecutionExerciseItemState extends State<ExecutionExerciseItem> {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<WorkoutSessionProvider>().session!;
    Exercise exercise = exercises.firstWhere((e) => e.id == widget.trainingExercise.exercise);

    final isCurrentExercise = session.exerciseIndex == widget.index;
    final isCompleted = session.isExerciseCompleted(widget.index);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.transparent,
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
                opacity: isCompleted ? AlwaysStoppedAnimation(0.5) : AlwaysStoppedAnimation(1),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(isCurrentExercise || isCompleted || widget.isNextExercise)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.gray : isCurrentExercise ? AppColors.primary : AppColors.completed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      maxLines: 1,
                      overflow: .visible,
                      isCompleted ? 'Realizado' : isCurrentExercise ? 'En ejecución' : 'Siguiente',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                Text(
                  exercise.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isCompleted ? AppColors.text : isCurrentExercise ? AppColors.primary : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? .lineThrough : .none
                  ),
                ),

                AutoSizeText(
                  maxLines: 1,
                  minFontSize: 12,
                  getTrainingSummary(widget.trainingExercise),
                  style: TextStyle(color: AppColors.text, decoration: isCompleted ? .lineThrough : .none),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Checkbox(
                value: session.isExerciseCompleted(widget.index),
                onChanged: (value) {
                  session.setExerciseCompleted(
                    widget.index,
                    value ?? false,
                  );
                },
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
