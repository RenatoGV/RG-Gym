import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/models/training_exercise.dart';

class ExerciseItem extends StatelessWidget {
  final TrainingExercise trainingExercise;
  final VoidCallback? onTap;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const ExerciseItem({
    super.key,
    required this.trainingExercise,
    this.onTap,
    this.onDuplicate,
    this.onDelete
  });

  @override
  Widget build(BuildContext context) {
    final Exercise exercise = exercises.firstWhere((exercise) => exercise.id == trainingExercise.exercise);

    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
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
              width: 90,
              height: 90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  exercise.gif,
                  fit: BoxFit.cover,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (trainingExercise.note != null && trainingExercise.note!.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red,
                          width: 1.3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        maxLines: 1,
                        overflow: .ellipsis,
                        trainingExercise.note!,
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),

                  const SizedBox(height: 10),

                  AutoSizeText(
                    maxLines: 1,
                    minFontSize: 12,
                    getTrainingSummary(trainingExercise),
                    style: TextStyle(color: AppColors.text),
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              color: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12)
              ),
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (value) {
                switch(value) {
                  case 'duplicate':
                    onDuplicate?.call();
                    break;
                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 20),
                      SizedBox(width: 10),
                      Text('Duplicar')
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20),
                      SizedBox(width: 10),
                      Text('Eliminar')
                    ],
                  ),
                ),
              ],
            ),
          ],
        )
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
