import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/models/muscle_group.dart';
import 'package:rg_gym/screens/tabs/exercises/tabs/instructions_tab.dart';
import 'package:rg_gym/screens/tabs/exercises/tabs/statistics_tab.dart';
import 'package:rg_gym/screens/tabs/exercises/tabs/history_tab.dart';
import 'package:rg_gym/shared/app_bar.dart';

enum ExerciseInfoTab {
  statistic,
  instructions,
  history
}

enum TabPosition {
  right,
  center,
  left
}

class ExerciseInfo extends StatefulWidget {
  final Exercise exercise;
  
  const ExerciseInfo({
    super.key,
    required this.exercise
  });

  @override
  State<ExerciseInfo> createState() => _ExerciseInfoState();
}

class _ExerciseInfoState extends State<ExerciseInfo> {
  ExerciseInfoTab selectedTab = ExerciseInfoTab.statistic;

  @override
  Widget build(BuildContext context) {
    List<MuscleGroup> primaryMuscles = widget.exercise.primaryMuscles.map((id) => muscleGroups.firstWhere((m) => m.id == id)).toList();
    List<MuscleGroup> secondaryMuscles = widget.exercise.secondaryMuscles.map((id) => muscleGroups.firstWhere((m) => m.id == id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.exercise.name,
        background: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const .symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Músculo${primaryMuscles.length > 1 ? 's' : ''} primario${primaryMuscles.length > 1 ? 's' : ''}: ',
                          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: primaryMuscles.map((m) => m.name).join(', '), style: TextStyle(color: AppColors.text)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if(secondaryMuscles.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Músculo${secondaryMuscles.length > 1 ? 's' : ''} secundario${secondaryMuscles.length > 1 ? 's' : ''}: ',
                            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: secondaryMuscles.map((m) => m.name).join(', '), style: TextStyle(color: AppColors.text)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 230,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      widget.exercise.gif,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                      title: 'Estadísticas',
                      tab: .statistic,
                      position: .left
                    )
                  ),
                  Expanded(
                    child: _tabButton(
                      title: 'Instrucciones',
                      tab: .instructions,
                      position: .center
                    )
                  ),
                  Expanded(
                    child: _tabButton(
                      title: 'Historial',
                      tab: .history,
                      position: .right
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: switch(selectedTab) {
                .statistic => StatisticsTab(exerciseId: widget.exercise.id),
                .instructions => InstructionsTab(exercise: widget.exercise),
                .history => HistoryTab(exerciseId: widget.exercise.id,),
              },
            ),
          ],
        ),
      )
    );
  }

  Widget _tabButton({ required String title, required ExerciseInfoTab tab, required TabPosition position }) {
    final selected = selectedTab == tab;

    BorderRadius radius = switch (position) {
      TabPosition.left => const BorderRadius.horizontal(left: Radius.circular(25)),
      TabPosition.center => BorderRadius.zero,
      TabPosition.right => const BorderRadius.horizontal(right: Radius.circular(25)),
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tab;
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