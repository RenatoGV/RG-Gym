import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/models/muscle_group.dart';

class InstructionsTab extends StatefulWidget {
  final Exercise exercise;

  const InstructionsTab({
    super.key,
    required this.exercise
  });

  @override
  State<InstructionsTab> createState() => _InstructionsTabState();
}

class _InstructionsTabState extends State<InstructionsTab> {
  @override
  Widget build(BuildContext context) {
    List<MuscleGroup> primaryMuscles = widget.exercise.primaryMuscles.map((id) => muscleGroups.firstWhere((m) => m.id == id)).toList();
    List<MuscleGroup> secondaryMuscles = widget.exercise.secondaryMuscles.map((id) => muscleGroups.firstWhere((m) => m.id == id)).toList();
    final exercise = widget.exercise;

    return Column(
      crossAxisAlignment: .start,
      children: [
        if(exercise.preparation.isNotEmpty)
          Column(
            crossAxisAlignment: .start,
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
            crossAxisAlignment: .start,
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
            crossAxisAlignment: .start,
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