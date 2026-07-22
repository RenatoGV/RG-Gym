import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/models/training_exercise.dart';

class ResumeExerciseItem extends StatefulWidget {
  final TrainingExercise trainingExercise;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const ResumeExerciseItem({
    super.key,
    required this.trainingExercise,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<ResumeExerciseItem> createState() => _ResumeExerciseItemState();
}

class _ResumeExerciseItemState extends State<ResumeExerciseItem> {
  @override
  Widget build(BuildContext context) {
    Exercise exercise = exercises.firstWhere((e) => e.id == widget.trainingExercise.exercise);

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
            width: 70,
            height: 70,
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
            child: Text(
              exercise.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            children: [
              Checkbox(
                value: widget.selected,
                onChanged: (value) => widget.onChanged(value ?? false),
              )
            ],
          )
        ],
      )
    );
  }
}