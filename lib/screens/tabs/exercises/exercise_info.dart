import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/models/muscle_group.dart';
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
                .statistic => const StatisticsTab(),
                .instructions => InstructionsTab(exercise: widget.exercise, primaryMuscles: primaryMuscles, secondaryMuscles: secondaryMuscles),
                .history => const HistoryTab(),
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

class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 50),
          Icon(
            Icons.bar_chart_sharp,
            color: AppColors.text,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            'Sin datos para el gráfico',
            style: TextStyle(color: AppColors.text),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class InstructionsTab extends StatelessWidget {
  final Exercise exercise;
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;

  const InstructionsTab({
    super.key,
    required this.exercise,
    required this.primaryMuscles,
    required this.secondaryMuscles
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        if(exercise.preparation.isNotEmpty)
          Column(
            children: [
              const Text(
                "Preparación",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(exercise.preparation, style: TextStyle(color: AppColors.text)),

              const SizedBox(height: 20),
            ],
          ),

        if(exercise.execution.isNotEmpty)
          Column(
            children: [
              const Text(
                "Ejecución",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  exercise.execution.length,
                  (index) => Padding(
                    padding: .only(bottom: 5),
                    child: Text(
                      '${index + 1}- ${exercise.execution[index]}',
                      style: const TextStyle(color: AppColors.text),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),

        if(exercise.details.isNotEmpty)
          Column(
            children: [
              const Text(
                "Detalles",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  exercise.details.length,
                  (index) => Padding(
                    padding: .only(bottom: 5),
                    child: Text(
                      '• ${exercise.details[index]}',
                      style: const TextStyle(color: AppColors.text),
                    )
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 10),
        const Divider(color: AppColors.backgroundSecondary),
        const SizedBox(height: 10),

        const Text(
          "Musculatura",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

                    ...primaryMuscles
                      .where((m) => m.type == .front || m.type == .both)
                      .map(
                        (m) => Image.asset(
                          'assets/images/muscles/frente_gm${m.id}.png',
                          fit: .contain,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        )
                      ),

                    ...secondaryMuscles
                      .where((m) => m.type == .front || m.type == .both)
                      .map(
                        (m) => Image.asset(
                          'assets/images/muscles/frente_gm${m.id}.png',
                          fit: .contain,
                          color: AppColors.secondary.withValues(alpha: 0.6),
                        )
                      ),
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

                    ...primaryMuscles
                      .where((m) => m.type == .back || m.type == .both)
                      .map(
                        (m) => Image.asset(
                          'assets/images/muscles/tras_gm${m.id}.png',
                          fit: .contain,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        )
                      ),

                    ...secondaryMuscles
                      .where((m) => m.type == .back || m.type == .both)
                      .map(
                        (m) => Image.asset(
                          'assets/images/muscles/tras_gm${m.id}.png',
                          fit: .contain,
                          color: AppColors.secondary.withValues(alpha: 0.6),
                        )
                      ),
                  ],
                )
              ),
            ],
          )
        ),
        const SizedBox(height: 30),
        Row(
          spacing: 3,
          children: [
            Container(
              height: 7,
              width: 7,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(100)
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Músculo${primaryMuscles.length > 1 ? 's' : ''} primario${primaryMuscles.length > 1 ? 's' : ''}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: primaryMuscles.map((m) => m.name).join(', ')),
                  ],
                ),
              ),
            ),
          ],
        ),
        if(secondaryMuscles.isNotEmpty)
          Column(
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 10),
              Row(
                spacing: 3,
                children: [
                  Container(
                    height: 7,
                    width: 7,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(100)
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Músculo${secondaryMuscles.length > 1 ? 's' : ''} secundario${secondaryMuscles.length > 1 ? 's' : ''}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: secondaryMuscles.map((m) => m.name).join(', ')),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 50),
          Icon(
            Icons.history,
            color: AppColors.text,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            'No hay historial',
            style: TextStyle(color: AppColors.text),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}