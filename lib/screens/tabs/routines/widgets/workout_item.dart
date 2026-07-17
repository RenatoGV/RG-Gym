import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/weekdays.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/weekday.dart';
import 'package:rg_gym/models/workout.dart';

class WorkoutlItem extends StatelessWidget {
  final String routineId;
  final Workout workout;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const WorkoutlItem({
    super.key,
    required this.routineId,
    required this.workout,
    this.onEdit,
    this.onDuplicate,
    this.onDelete
  });

  @override
  Widget build(BuildContext context) {
    int exercisesCount = (workout.trainingExercises != null) ? workout.trainingExercises!.length : 0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/workout',
        arguments: {
          'routineId': routineId,
          'workoutId': workout.id
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${getTimeSummary(workout)} • $exercisesCount ejercicios • ${getCaloriesSummary(workout)}',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 10
                    ),
                  )
                ],
              )
            ),

            if ((workout.days?.isNotEmpty ?? false)) buildDays(workout.days!),

            const SizedBox(width: 8),

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
                  case 'edit':
                    onEdit?.call();
                    break;
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
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 10),
                      Text('Editar')
                    ],
                  ),
                ),
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
        ),
      ),
    );
  }
}

Widget buildDays(List<String> days) {
  const maxVisible = 3;
  const chipSize = 30.0;
  const overlap = 7.0;

  final hasMore = days.length > maxVisible;

  final items = hasMore
      ? [...days.take(maxVisible - 1), null]
      : days;

  final width = chipSize + (items.length - 1) * (chipSize - overlap);

  return SizedBox(
    width: width,
    height: chipSize,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        for (int i = 0; i < items.length; i++)
          Positioned(
            left: i * (chipSize - overlap),
            child: items[i] == null
                ? _moreChip()
                : _dayChip(items[i]!),
          ),
      ],
    ),
  );
}

Widget _dayChip(String key) {
  final WeekDay day = weekdays.firstWhere((weekday) => weekday.key == key);

  return Container(
    width: 30,
    height: 30,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: day.color,
      shape: BoxShape.circle,
    ),
    child: Text(
      day.name.substring(0, 3),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _moreChip() {
  return Container(
    width: 30,
    height: 30,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Colors.grey,
      shape: BoxShape.circle,
    ),
    child: const Text(
      '...',
      style: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

String getCaloriesSummary(Workout workout) {
  final total = (workout.trainingExercises ?? [])
    .expand((t) => t.sets)
    .fold<double>(0, (sum, set) => sum + (set.reps ?? 0));

  return '${FormatHelper.formatDouble(total)} kcal';
}


String getTimeSummary(Workout workout) {
  const exerciseRest = 60;
  final exercises = workout.trainingExercises ?? [];

  int totalSeconds = 0;

  for (int i = 0; i < exercises.length; i++) {
    final exercise = exercises[i];

    for (int j = 0; j < exercise.sets.length; j++) {
      final set = exercise.sets[j];

      switch (exercise.type) {
        case .repsWeight:
        case .reps:
          totalSeconds += (set.reps ?? 0);
          break;
        case .time:
          totalSeconds += set.time?.inSeconds ?? 0;
          break;
        case .weight:
          totalSeconds += 1;
          break;
      }

      if(j < exercise.sets.length - 1) {
        totalSeconds += exercise.restTime;
      }
    }

    if(i < exercises.length - 1) {
      totalSeconds += exerciseRest;
    }
  }

  final min = (totalSeconds ~/ 600) * 10;
  final max = min + 10;

  return '${exercises.isNotEmpty ? max : '0'} min';
}