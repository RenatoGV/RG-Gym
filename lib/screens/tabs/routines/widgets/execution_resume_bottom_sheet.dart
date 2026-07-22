import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/history_workout.dart';
import 'package:rg_gym/providers/history_provider.dart';
import 'package:rg_gym/providers/workout_session_provider.dart';
import 'package:rg_gym/screens/tabs/routines/widgets/resume_exercise_item.dart';
import 'package:uuid/uuid.dart';

class ExecutionResumeBottomSheet extends StatefulWidget {
  const ExecutionResumeBottomSheet({super.key});

  @override
  State<ExecutionResumeBottomSheet> createState() => _ExecutionResumeBottomSheetState();
}

class _ExecutionResumeBottomSheetState extends State<ExecutionResumeBottomSheet> {
  late List<HistoryTrainingExercise> historyExercises;
  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<WorkoutSessionProvider>().session;

    if (session == null) {
      return const SizedBox.shrink();
    }

    if (!initialized) {
      historyExercises = session.workout.trainingExercises!.map((e) => HistoryTrainingExercise(trainingExercise: e, completed: true)).toList();
      initialized = true;
    }

    final completedExercises = historyExercises.where((e) => e.completed).map((e) => e.trainingExercise).toList();

    final int completedExercisesTotal = completedExercises.length;
    final int completedSets = completedExercises.fold(0, (sum, e) => sum + e.sets.length);
    final int completedReps = completedExercises.fold(0, (sum, e) => sum + e.sets.fold(0, (setSum, s) => setSum + (s.reps ?? 0)));
    final double totalWeight = completedExercises.fold(0.0, (sum, e) => sum + e.sets.fold(0.0, (setSum, s) => setSum + (s.weight ?? 0) * (s.reps ?? 0)));
    final int totalExercises = historyExercises.length;
    
    final Map<String, double> muscleFatigue = {};
    void addMuscle(List<int> muscles, double amount) {
      for(final muscleId in muscles) {
        final muscleName = muscleGroups.firstWhere((m) => m.id == muscleId).name;

        muscleFatigue[muscleName] = ((muscleFatigue[muscleName] ?? 0) + amount).clamp(0.0, 1.0);
      }
    }
    for(final te in completedExercises) {
      final exercise = exercises.firstWhere((e) => e.id == te.exercise);

      addMuscle(exercise.primaryMuscles, 0.3);
      addMuscle(exercise.secondaryMuscles, 0.1);
    }
    final sortedMuscleFatigue = muscleFatigue.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final today = DateTime.now();
    final todayFormatted = DateFormat('d MMM yyyy', 'es').format(today);
    
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.95,
      minChildSize: 0.60,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.95],
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),

                      const SizedBox(width: 4),

                      const Text(
                        "Informe",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      ListView(
                        controller: scrollController,
                        padding: .symmetric(horizontal: 20),
                        children: [
                          const Text("Fecha", style: TextStyle(fontSize: 16, fontWeight: .w600)),
                          const SizedBox(height: 10),
                          Container(
                            padding: .symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: AppColors.backgroundSecondary),
                              borderRadius: BorderRadius.circular(7)
                            ),
                            child: Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Text(todayFormatted, style: TextStyle(color: AppColors.text)),
                                const Icon(Icons.lock, color: AppColors.primary)
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Text("Ejercicios realizados", style: TextStyle(fontSize: 16, fontWeight: .w600)),
                          const SizedBox(height: 10),
                          Column(
                            children: List.generate(
                              historyExercises.length,
                              (index) {
                                final historyExercise = historyExercises[index];

                                return Padding(
                                  padding: .only(bottom: index == session.workout.trainingExercises!.length - 1 ? 0 : 10),
                                  child: ResumeExerciseItem(
                                    trainingExercise: historyExercise.trainingExercise,
                                    selected: historyExercise.completed,
                                    onChanged: (selected) {
                                      setState(() {
                                        historyExercise.completed = selected;
                                      });
                                    },
                                  )
                                );
                              }
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Text("Resumen de entrenamiento", style: TextStyle(fontSize: 16, fontWeight: .w600)),
                          const SizedBox(height: 10),
                          Container(
                            padding: .symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: AppColors.backgroundSecondary),
                              borderRadius: BorderRadius.circular(7)
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [
                                    const Text('Concluido', style: TextStyle(color: AppColors.text)),
                                    Row(
                                      children: [
                                        Text('${(completedExercisesTotal/totalExercises * 100).round()}', style: TextStyle(fontSize: 15, fontWeight: .w500)),
                                        const Text('%', style: TextStyle(fontSize: 10, fontWeight: .w500)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: completedExercisesTotal / totalExercises,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(10),
                                  backgroundColor: AppColors.backgroundSecondary,
                                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _resumeBoxDetail('Ejercicios', '$completedExercisesTotal'),
                              const SizedBox(width: 5),
                              _resumeBoxDetail('Series', '$completedSets'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _resumeBoxDetail('Repeticiones', '$completedReps'),
                              const SizedBox(width: 5),
                              _resumeBoxDetail('Carga', '${FormatHelper.formatDouble(totalWeight)} kg'),
                            ],
                          ),

                          const SizedBox(height: 30),

                          const Text("Hora", style: TextStyle(fontSize: 16, fontWeight: .w600)),
                          const SizedBox(height: 10),
                          _timeStat(session.executionDuration, session.restDuration, session.preparationDuration),

                          if(sortedMuscleFatigue.isNotEmpty)
                            Column(
                              crossAxisAlignment: .start,
                              children: [
                                const SizedBox(height: 30),
                                const Text("Fatiga muscular", style: TextStyle(fontSize: 16, fontWeight: .w600)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: .symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 2, color: AppColors.backgroundSecondary),
                                    borderRadius: BorderRadius.circular(7)
                                  ),
                                  child: Column(
                                    children: List.generate(
                                      sortedMuscleFatigue.length,
                                      (index) {
                                        final entry = sortedMuscleFatigue[index];

                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: _muscleFatigueItem(
                                            entry.key,
                                            entry.value,
                                          ),
                                        );
                                      }
                                    ),
                                  )
                                ),
                              ],
                            ),
                          const SizedBox(height: 100)
                        ],
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: SafeArea(
                          top: false,
                          child: SizedBox(
                            height: 50,
                            child: FilledButton(
                              onPressed: () => {
                                saveHistory(today),
                                Navigator.of(context).pop(true)
                              },
                              child: const Text("Finalizar entrenamiento"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> saveHistory(DateTime date) async {
    final session = context.read<WorkoutSessionProvider>().session;

    if (session == null) return;

    final HistoryWorkout history = HistoryWorkout(
      id:  const Uuid().v4(),
      name: session.workout.name,
      trainingExercises: historyExercises,
      date: date,
      restDuration: session.restDuration,
      executionDuration: session.executionDuration,
      preparationDuration: session.preparationDuration,
    );

    await context.read<HistoryProvider>().add(history);
  }
}


Widget _resumeBoxDetail(String title, String amount) {
  return Expanded(
    child: Container(
      padding: .symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: AppColors.backgroundSecondary),
        borderRadius: BorderRadius.circular(7)
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(title, style: TextStyle(color: AppColors.text)),
          Text(amount, style: TextStyle(fontSize: 18))
        ],
      ),
    ),
  );
}

Widget _timeStat(Duration executionTime, Duration restTime, Duration preparationTime) {
  Duration totalTime = executionTime + restTime + preparationTime;

  final totalMs = totalTime.inMilliseconds;

  final preparationPercent = totalMs == 0 ? 0.0 : preparationTime.inMilliseconds / totalMs * 100;

  final executionPercent = totalMs == 0 ? 0.0 : executionTime.inMilliseconds / totalMs * 100;

  final restPercent = totalMs == 0 ? 0.0 : restTime.inMilliseconds / totalMs * 100;

  return Container(
    padding: .symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(width: 2, color: AppColors.backgroundSecondary),
      borderRadius: BorderRadius.circular(7)
    ),
    child: Column(
      children: [
        Center(
          child: SizedBox(
            width: 180,
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: [
                  PieChartSectionData(
                    value: restPercent,
                    color: Colors.blue,
                    title: '${restPercent.toStringAsFixed(2)}%',
                    radius: 90,
                  ),
                  PieChartSectionData(
                    value: executionPercent,
                    color: Colors.green,
                    title: '${executionPercent.toStringAsFixed(2)}%',
                    radius: 90,
                  ),
                  PieChartSectionData(
                    value: preparationPercent,
                    color: Colors.orange,
                    title: '${preparationPercent.toStringAsFixed(2)}%',
                    radius: 90,
                  ),
                ],
              ),
            ),
          )
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(100)
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child:
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  const Text('Preparación'),
                  Text(durationString(preparationTime))
                ],
              )
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(100)
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child:
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  const Text('En ejecución'),
                  Text(durationString(executionTime))
                ],
              )
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(100)
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child:
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  const Text('Descanso'),
                  Text(durationString(restTime))
                ],
              )
            ),
          ],
        ),
        const Divider(color: AppColors.gray),
        Row(
          children: [
            Expanded(child:
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  const Text('Tiempo total', style: TextStyle(color: AppColors.primary, fontWeight: .bold)),
                  Text(durationString(totalTime))
                ],
              )
            ),
          ],
        ),
      ],
    )
  );
}

String durationString(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  final parts = <String>[];

  if(hours > 0) parts.add('$hours h');
  if(minutes > 0) parts.add('$minutes m');
  if(seconds > 0 || parts.isEmpty) parts.add('$seconds s');

  return parts.join(' ');
}

Widget _muscleFatigueItem(String muscle, double value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(muscle),
          Text('${(value * 100).round()}%'),
        ],
      ),
      const SizedBox(height: 10),
      _progressBar(value),
    ],
  );
}

Widget _progressBar(double value) {
  const gap = 4.0;

  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final progressWidth = width * value;

      return SizedBox(
        height: 6,
        child: Row(
          children: [
            Container(
              width: progressWidth,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            if (value > 0 && value < 1) SizedBox(width: gap),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}