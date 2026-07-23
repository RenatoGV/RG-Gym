import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/history_workout.dart';
import 'package:rg_gym/models/muscle_group.dart';
import 'package:rg_gym/providers/history_provider.dart';
import 'package:rg_gym/screens/tabs/stats/widgets/equipment_stat.dart';
import 'package:rg_gym/screens/tabs/stats/widgets/muscle_count_list.dart';

enum FilterDays {
  seven,
  fourteen,
  twentyEight,
  ninety
}

enum TabPosition {
  right,
  center,
  left
}

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  FilterDays selectedFilter = FilterDays.seven;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().history;

    List<HistoryWorkout> getByFilter() {
      final now = DateTime.now();

      return switch (selectedFilter) {
        .seven => history.where((h) {
          return now.difference(h.date).inDays < 7;
        }).toList(),
        .fourteen => history.where((h) {
          return now.difference(h.date).inDays < 14;
        }).toList(),
        .twentyEight => history.where((h) {
          return now.difference(h.date).inDays < 28;
        }).toList(),
        .ninety => history.where((h) {
          return now.difference(h.date).inDays < 90;
        }).toList(),
      };
    }

    int totalExercises() {
      final total = getByFilter()
          .fold(
            0,
            (sum, h) => sum + (h.completedExercises.length),
          );

      return total;
    }

    String totalDuration() {
      final total = getByFilter().fold<Duration>(Duration.zero, (sum, h) => sum + h.totalDuration);

      final hours = total.inHours;
      final minutes = total.inMinutes.remainder(60);
      final seconds = total.inSeconds.remainder(60);

      return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
    }

    String totalDurationLabel() {
      final total = getByFilter().fold<Duration>(Duration.zero, (sum, h) => sum + h.totalDuration);

      if(total.inHours > 0) return 'h';
      if(total.inMinutes > 0) return 'm';
      return 's';
    }

    String getCaloriesSummary() {
      final total = getByFilter()
        .expand((h) => h.completedExercises)
        .expand((t) => t.sets)
        .fold<double>(
          0,
          (sum, set) => sum + (set.reps ?? 0),
        );

      return FormatHelper.formatDouble(total);
    }

    int getTotalSeries() {
      return getByFilter()
          .fold(
            0,
            (sum, h) => sum + (h.completedSets),
          );
    }

    int getTotalReps() {
      return getByFilter()
          .fold(
            0,
            (sum, h) => sum + (h.completedReps),
          );
    }

    String getTotalWeight() {
      final total = getByFilter()
        .fold<double>(0, (sum, h) => sum + (h.totalWeight));

      final roundedTotal = double.parse(total.toStringAsFixed(2));

      return FormatHelper.formatDouble(roundedTotal);
    }

    Set<MuscleGroup> allMusclesWorked() {
      return getByFilter()
        .expand((h) => h.completedExercises)
        .expand((t) {
          final exercise = exercises.firstWhere((e) => e.id == t.exercise);

          return [
            ...exercise.primaryMuscles,
            ...exercise.secondaryMuscles,
          ];
        })
        .map((id) => muscleGroups.firstWhere((m) => m.id == id))
        .toSet();
    }

    Map<int, int> muscleCount() {
      final muscles = <int, int>{};

      for (final he in getByFilter().expand((h) => h.completedExercises)) {
        final exercise = exercises.firstWhere((e) => e.id == he.exercise);

        for (final muscleId in exercise.primaryMuscles) {
          muscles.update(muscleId, (count) => count + 3, ifAbsent: () => 3);
        }

        for (final muscleId in exercise.secondaryMuscles) {
          muscles.update(muscleId, (count) => count + 1, ifAbsent: () => 1);
        }
      }

      return Map.fromEntries(
        muscles.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );
    }

    Map<int, int> equipmentCount() {
      final equipment = <int, int> {};

      for (final he in getByFilter().expand((h) => h.completedExercises)) {
        final exercise = exercises.firstWhere((e) => e.id == he.exercise);

        for (final equipmentId in exercise.equipment) {
          equipment.update(equipmentId, (count) => count + 1, ifAbsent: () => 1);
        }
      }

      return Map.fromEntries(
        equipment.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value))
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const .symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            const Text("Fatiga Muscular", style: TextStyle(fontSize: 16, fontWeight: .w600)),
            const SizedBox(height: 5),
            const Text("Controlar los niveles de fatiga muscular",style: TextStyle(color: AppColors.text)),
            const SizedBox(height: 10),
            Container(
              padding: .symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: AppColors.backgroundSecondary),
                borderRadius: BorderRadius.circular(7)
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 25),
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

                              // ...historyWorkout.musclesWorked
                              //   .where((m) => m.type == .front)
                              //   .map(
                              //     (m) => Image.asset(
                              //       'assets/images/muscles/frente_gm${m.id}.png',
                              //       fit: .contain,
                              //       color: AppColors.primary.withValues(alpha: 0.6),
                              //     )
                              //   )
                            ],
                          )
                        ),

                        const SizedBox(width: 50),

                        Expanded(
                          child: Stack(
                            alignment: .center,
                            children: [
                              Image.asset(
                                'assets/images/tras_base.png',
                                fit: BoxFit.contain,
                              ),

                              // ...historyWorkout.musclesWorked
                              //   .where((m) => m.type == .back)
                              //   .map(
                              //     (m) => Image.asset(
                              //       'assets/images/muscles/tras_gm${m.id}.png',
                              //       fit: .contain,
                              //       color: AppColors.primary.withValues(alpha: 0.6),
                              //     )
                              //   )
                            ],
                          )
                        ),
                      ],
                    )
                  ),

                  const SizedBox(height: 30),
                  TextButton.icon(
                    onPressed: () {},
                    label: Text('Ver detalles', style: TextStyle(color: AppColors.primary, fontWeight: .bold)),
                    icon: Icon(Icons.navigate_next_rounded, color: AppColors.primary),
                    iconAlignment: .end,
                  )
                ]
              )
            ),

            const SizedBox(height: 30),

            const Text("Estadísticas", style: TextStyle(fontSize: 16, fontWeight: .w600)),
            const SizedBox(height: 10),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: .circular(25)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _tabButton(
                      title: '7 días',
                      tab: .seven,
                      position: .left
                    )
                  ),
                  Expanded(
                    child: _tabButton(
                      title: '14 días',
                      tab: .fourteen,
                      position: .center
                    )
                  ),
                  Expanded(
                    child: _tabButton(
                      title: '28 días',
                      tab: .twentyEight,
                      position: .center
                    )
                  ),
                  Expanded(
                    child: _tabButton(
                      title: '90 días',
                      tab: .ninety,
                      position: .right
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Hiciste ',
                    style: TextStyle(
                      color: AppColors.text
                    )
                  ),
                  TextSpan(
                    text: '${totalExercises()} ejercicio${totalExercises() == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: ' en los últimos ',
                    style: TextStyle(
                      color: AppColors.text
                    )
                  ),
                  TextSpan(
                    text: daysText(selectedFilter),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              )
            ),
            const SizedBox(height: 10),
            _activityBoxDetail('Duración de los ejercicios', totalDuration(), totalDurationLabel()),
            const SizedBox(height: 10),
            _activityBoxDetail('Calorías', getCaloriesSummary(), 'kcal'),
            const SizedBox(height: 10),
            _activityBoxDetail('Ejercicios', '${totalExercises()}', 'ejercicio${totalExercises() == 1 ? '' : 's'}'),
            const SizedBox(height: 10),
            Row(
              spacing: 10,
              children: [
                _activityBox('Series', '${getTotalSeries()}', 'series'),
                _activityBox('Reps', '${getTotalReps()}', 'rep${getTotalReps() == 1 ? '' : 's'}'),
                _activityBox('Carga', getTotalWeight(), 'kg'),
              ],
            ),

            const SizedBox(height: 30),

            const Text("Regiones más entrenadas", style: TextStyle(fontSize: 16, fontWeight: .w600)),
            const SizedBox(height: 5),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Últimos ',
                    style: TextStyle(
                      color: AppColors.primary
                    )
                  ),
                  TextSpan(
                    text: daysText(selectedFilter),
                    style: const TextStyle(
                      color: AppColors.primary,
                    ),
                  ),
                ]
              )
            ),
            const SizedBox(height: 10),
            Container(
              padding: .symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: AppColors.backgroundSecondary),
                borderRadius: BorderRadius.circular(7)
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 25),
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

                              ...allMusclesWorked()
                                .where((m) => m.type == .front)
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

                        const SizedBox(width: 50),

                        Expanded(
                          child: Stack(
                            alignment: .center,
                            children: [
                              Image.asset(
                                'assets/images/tras_base.png',
                                fit: BoxFit.contain,
                              ),

                              ...allMusclesWorked()
                                .where((m) => m.type == .back)
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
                  MuscleCountList(muscleCount: muscleCount())
                ]
              )
            ),

            const SizedBox(height: 30),

            const Text("Tipos de ejercicios", style: TextStyle(fontSize: 16, fontWeight: .w600)),
            const SizedBox(height: 5),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Últimos ',
                    style: TextStyle(
                      color: AppColors.primary
                    )
                  ),
                  TextSpan(
                    text: daysText(selectedFilter),
                    style: const TextStyle(
                      color: AppColors.primary,
                    ),
                  ),
                ]
              )
            ),
            const SizedBox(height: 10),
            EquipmentStat(equipmentCount: equipmentCount())
          ],
        )
      )
    );
  }

  Widget _tabButton({ required String title, required FilterDays tab, required TabPosition position }) {
    final selected = selectedFilter == tab;

    BorderRadius radius = switch (position) {
      TabPosition.left => const BorderRadius.horizontal(left: Radius.circular(25)),
      TabPosition.center => BorderRadius.zero,
      TabPosition.right => const BorderRadius.horizontal(right: Radius.circular(25)),
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = tab;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: .center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: radius
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.text,
            fontWeight: .w600
          ),
        ),
      ),
    );
  }
}

String daysText(FilterDays filter) {
  return switch (filter) {
    .seven => '7 días',
    .fourteen => '14 días',
    .twentyEight => '28 días',
    .ninety => '90 días',
  };
}

Widget _activityBoxDetail(String title, String amount, String label) {
  return Container(
    width: .infinity,
    padding: .symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(width: 2, color: AppColors.backgroundSecondary),
      borderRadius: BorderRadius.circular(7)
    ),
    child: Row(
      mainAxisAlignment: .spaceBetween,
      crossAxisAlignment: .start,
      children: [
        Column(
          crossAxisAlignment: .start,
          children: [
            Text(title, style: TextStyle(color: AppColors.text)),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: amount,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: .bold
                    )
                  ),
                  TextSpan(
                    text: ' $label',
                    style: TextStyle(
                      fontSize: 12
                    )
                  ),
                ]
              )
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {},
          label: Text('Ver detalles', style: TextStyle(color: AppColors.text)),
          icon: Icon(Icons.navigate_next_rounded, color: AppColors.text),
          iconAlignment: .end,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        )
      ],
    )
  );
}

Widget _activityBox(String title, String amount, String label) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: AppColors.backgroundSecondary,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: .center,
        children: [
          Text(title, style: const TextStyle(color: AppColors.text)),
          const SizedBox(height: 40),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: amount,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: .bold
                  )
                ),
                TextSpan(
                  text: ' $label',
                  style: TextStyle(
                    fontSize: 12
                  )
                ),
              ]
            )
          ),
        ],
      ),
    ),
  );
}