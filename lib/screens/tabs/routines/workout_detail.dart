import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/muscle_group.dart';
import 'package:rg_gym/models/workout.dart';
import 'package:rg_gym/providers/routines_provider.dart';
import 'package:rg_gym/providers/workout_session_provider.dart';
import 'package:rg_gym/screens/tabs/routines/widgets/exercise_item.dart';
import 'package:rg_gym/service/battery_optimization.dart';
import 'package:rg_gym/shared/app_bar.dart';

class WorkoutDetail extends StatelessWidget {
  const WorkoutDetail({ super.key });

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final routineId = args['routineId'];
    final workoutId = args['workoutId'];

    final Workout workout = context.watch<RoutinesProvider>().getWorkoutById(routineId, workoutId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: workout.name,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  headerItem('timer.png', 'Duración', getTimeSummary(workout)),
                  headerItem('fire.png', 'Calorías', getCaloriesSummary(workout)),
                  headerItem('weight.png', 'Carga', getWeightSummary(workout)),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if(workout.trainingExercises == null || workout.trainingExercises!.isEmpty) return;

                      final provider = context.read<WorkoutSessionProvider>();

                      final batteryEnabled = await BatteryOptimization.isDisabled();

                      if(!context.mounted) return;

                      if(!batteryEnabled) {
                        final configure = await showBatteryDialog(context);

                        if(!configure) return;

                        if(!context.mounted) return;
                      }

                      await provider.startWorkout(workout);

                      if(!context.mounted) return;
                      
                      await Navigator.pushNamed(context, '/execution');
                    },
                    child: const Text(
                      'Iniciar entrenamiento',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              )
            ],
          ),
        )
      ),
      body: (workout.trainingExercises == null || workout.trainingExercises!.isEmpty) ?
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/dumbbell.svg',
                width: 50,
                height: 50
              ),
              const SizedBox(height: 8),
              const Text('Ejercicios', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: .bold)),
              const SizedBox(height: 4),
              const Text('Añade ejercicios a tu entrenamiento', style: TextStyle(color: AppColors.text)),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    '/exercises',
                    arguments: {
                      'workout': workout,
                      'routineId': routineId
                    }
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Agregar ejercicios",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      : CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  'Lista de ejercicios',
                  style: TextStyle(fontWeight: .bold),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverReorderableList(
              itemCount: workout.trainingExercises?.length ?? 0,

              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final t = Curves.easeOut.transform(animation.value);

                    return Transform.scale(
                      scale: lerpDouble(1.0, 1.05, t)!,
                      child: child,
                    );
                  },
                );
              },
              
              onReorder: (oldIndex, newIndex) async {
                await context.read<RoutinesProvider>().reorderTrainingExercises(
                  routineId,
                  workoutId,
                  oldIndex,
                  newIndex,
                );
              },

              itemBuilder: (context, index) {
                final trainingExercise = workout.trainingExercises![index];

                return ReorderableDelayedDragStartListener(
                  key: ValueKey(trainingExercise.id),
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ExerciseItem(
                      trainingExercise: trainingExercise,

                      onTap: () => Navigator.pushNamed(context, '/workout/exercise', arguments: {
                        'routineId': routineId,
                        'workoutId': workoutId,
                        'trainingExerciseId': trainingExercise.id
                      }),

                      onDuplicate: () async => await context.read<RoutinesProvider>().duplicateTrainingExercise(routineId, workoutId, trainingExercise),

                      onDelete: () async => await context.read<RoutinesProvider>().removeTrainingExercise(routineId, workoutId, trainingExercise.id),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "Musculatura",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 50),
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: .center,
                          children: [
                            Image.asset(
                              'assets/images/frente_base.png',
                              fit: BoxFit.contain,
                            ),

                            ...getMusclesWorked(workout)
                              .where((m) => m.type == .front || m.type == .both)
                              .map(
                                (m) => Image.asset(
                                  'assets/images/muscles/frente_gm${m.id}.png',
                                  fit: .contain,
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                )
                              )
                          ],
                        )
                      ),

                      const SizedBox(width: 100),

                      Expanded(
                        child: Stack(
                          alignment: .center,
                          children: [
                            Image.asset(
                              'assets/images/tras_base.png',
                              fit: BoxFit.contain,
                            ),

                            ...getMusclesWorked(workout)
                              .where((m) => m.type == .back || m.type == .both)
                              .map(
                                (m) => Image.asset(
                                  'assets/images/muscles/tras_gm${m.id}.png',
                                  fit: .contain,
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                )
                              )
                          ],
                        )
                      ),
                    ],
                  )
                ),

                const SizedBox(height: 30),

                Text(
                  getMusclesWorkedSummary(workout),
                  style: TextStyle(color: AppColors.text),
                  textAlign: .center,
                ),

                const SizedBox(height: 100),
              ]
            )
          )
        ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/exercises',
            arguments: {
              'workout': workout,
              'routineId': routineId
            }
          );
        },
        label: Text('Agregar', style: TextStyle(fontWeight: FontWeight.w900)),
        icon: Icon(Icons.add, fontWeight: FontWeight.w900),
      ),
    );
  }
}

Widget headerItem(String image, String title, String subtitle) {
  return Row(
    spacing: 5,
    children: [
      Image.asset(
        'assets/images/$image',
        height: 30,
      ),
      Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: AppColors.text),
          )
        ],
      )
    ],
  );
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
          totalSeconds += (set.reps ?? 0) * 3;
          break;
        case .time:
          totalSeconds += set.time?.inSeconds ?? 0;
          break;
        case .weight:
          totalSeconds += 3;
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

  return '${exercises.isNotEmpty ? '$min-$max' : '-'} min';
}

String getCaloriesSummary(Workout workout) {
  final total = (workout.trainingExercises ?? [])
    .expand((t) => t.sets)
    .fold<double>(0, (sum, set) => sum + (set.reps ?? 0));

  return '${total > 0 ? FormatHelper.formatDouble(total) : '-'} kcal';
}

String getWeightSummary(Workout workout) {
  final total = (workout.trainingExercises ?? [])
    .expand((t) => t.sets)
    .fold<double>(0, (sum, set) => sum + (set.weight ?? 0));

  final roundedTotal = double.parse(total.toStringAsFixed(2));

  return '${roundedTotal > 0 ? FormatHelper.formatDouble(roundedTotal) : '-'} kg';
}

String getMusclesWorkedSummary(Workout workout) {
  final muscles = <String>{};

  for (final t in workout.trainingExercises ?? []) {
    final exercise = exercises.firstWhere((e) => e.id == t.exercise);

    for (final muscleId in [...exercise.primaryMuscles, ...exercise.secondaryMuscles]) {
      muscles.add(muscleGroups.firstWhere((m) => m.id == muscleId).name);
    }
  }

  return muscles.join(', ');
}

Set<MuscleGroup> getMusclesWorked(Workout workout) {
  final muscles = <MuscleGroup>{};

  for (final t in workout.trainingExercises ?? []) {
    final exercise = exercises.firstWhere((e) => e.id == t.exercise);

    for (final muscleId in [...exercise.primaryMuscles, ...exercise.secondaryMuscles]) {
      muscles.add(muscleGroups.firstWhere((m) => m.id == muscleId));
    }
  }

  return muscles;
}

Future<bool> showBatteryDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Optimización de batería', style: TextStyle(color: AppColors.primary, fontWeight: .bold)),
        content: const Text(
          'Para evitar que Android detenga el entrenamiento en segundo plano '
          'cuando la pantalla esté apagada, se recomienda desactivar la '
          'optimización de batería para RG Gym.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Omitir'),
          ),

          FilledButton(
            style: FilledButton.styleFrom(
              padding: .symmetric(horizontal: 10)
            ),
            onPressed: () async {
              await BatteryOptimization.openSettings();

              if(context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Configurar'),
          ),
        ],
      );
    }
  );

  return result ?? false;
}