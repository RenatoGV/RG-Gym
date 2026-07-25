import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/fatigued_muscle.dart';
import 'package:rg_gym/providers/muscle_fatigue_provider.dart';
import 'package:rg_gym/screens/tabs/stats/widgets/fatigue_state_item.dart';
import 'package:rg_gym/shared/app_bar.dart';

class MuscleFatigueScreen extends StatefulWidget {
  const MuscleFatigueScreen({super.key});

  @override
  State<MuscleFatigueScreen> createState() => _MuscleFatigueScreenState();
}

class _MuscleFatigueScreenState extends State<MuscleFatigueScreen> {
  @override
  Widget build(BuildContext context) {
    final fatiguedMuscles = context.watch<MuscleFatigueProvider>().fatiguedMuscles;

    final arms = fatiguedMuscles.where((m) => [0, 2, 3, 10].contains(m.muscleId)).toList();

    final superiorParts = fatiguedMuscles.where((m) => [1, 4, 5].contains(m.muscleId)).toList();

    final legs = fatiguedMuscles.where((m) => [6, 7, 8, 13, 14, 15].contains(m.muscleId)).toList();

    final back = fatiguedMuscles.where((m) => [9, 11, 12].contains(m.muscleId)).toList();

    final cardio = fatiguedMuscles.where((m) => [16].contains(m.muscleId)).toList();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Fatiga muscular",
        background: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const .symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 20),
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

                          ...fatiguedMuscles
                            .where((m) => m.muscle.type == .front || m.muscle.type == .both)
                            .map(
                              (m) => Image.asset(
                                'assets/images/muscles/frente_gm${m.muscleId}.png',
                                fit: .contain,
                                color: m.stateColor.withValues(alpha: 0.6),
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

                          ...fatiguedMuscles
                            .where((m) => m.muscle.type == .back || m.muscle.type == .both)
                            .map(
                              (m) => Image.asset(
                                'assets/images/muscles/tras_gm${m.muscleId}.png',
                                fit: .contain,
                                color: m.stateColor.withValues(alpha: 0.6),
                              )
                            )
                        ],
                      )
                    ),
                  ],
                )
              ),

              const SizedBox(height: 30),

              Padding(
                padding: .symmetric(horizontal: 25),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runAlignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FatigueStateItem(state: .weakened),
                    FatigueStateItem(state: .recovering),
                    FatigueStateItem(state: .recovered),
                    FatigueStateItem(state: .fatigued),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              _fatigueSection('Brazos', arms),
              const SizedBox(height: 30),
              _fatigueSection('Parte superior del cuerpo', superiorParts),
              const SizedBox(height: 30),
              _fatigueSection('Piernas', legs),
              const SizedBox(height: 30),
              _fatigueSection('Espalda', back),
              const SizedBox(height: 30),
              _fatigueSection('Cardio', cardio),
            ],
          ),
        )
      ),
    );
  }

  Widget _fatigueSection(String title, List<FatiguedMuscle> muscles) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: .w600)),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: muscles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            return _fatigueBox(muscles[index]);
          },
        ),
      ],
    );
  }

  Widget _fatigueBox(FatiguedMuscle fatiguedMuscle) {
    return GestureDetector(
      onTap: () => showFatigueDialog(context, fatiguedMuscle),
      child: Container(
        padding: .symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: fatiguedMuscle.stateColor,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(3), right: Radius.circular(8)),
              child: LinearProgressIndicator(
                value: fatiguedMuscle.fatigued / 1,
                minHeight: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.5),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(fatiguedMuscle.muscle.name, style: const TextStyle(fontWeight: .w500)),
          ],
        ),
      )
    );
  }
}


void showFatigueDialog(BuildContext context, FatiguedMuscle fatiguedMuscle) {
  double value = fatiguedMuscle.fatigued;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          FatigueState state = switch(value) {
            <= 0.15 => .weakened,
            <= 0.4 => .recovered,
            <= 0.7 => .recovering,
            _ => .fatigued
          };

          final stateName = switch(state) {
            .weakened => 'debilitado',
            .recovered => 'recuperado',
            .recovering => 'en recuperación',
            .fatigued => 'fatigado'
          };

          Color stateColor = switch(state) {
            .weakened => Colors.green,
            .recovered => Colors.blue,
            .recovering => Colors.amber,
            .fatigued => Colors.red
          };

          return AlertDialog(
            title: Text(fatiguedMuscle.muscle.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: .center),
            content: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                const Text('Nivel de fatiga muscular'),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 25,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(
                      stateColor,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: stateColor,
                        shape: .circle
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text('Músculo $stateName'),
                  ],
                ),

                const SizedBox(height: 20),

                const Text('Ajuste manual'),
                Padding(
                  padding: const .symmetric(vertical: 10),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: value,
                      min: 0,
                      max: 1,
                      divisions: 100,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.backgroundSecondary,
                      onChanged: (newValue) {
                        setState(() {
                          value = newValue;
                        });
                      },
                    ),
                  ),
                ),

                const Text(
                  'Los niveles de fatiga muscular pueden actualizarse manualmente. A medida que pasan las horas, las tasas de fatiga disminuirán automáticamente, estimando cuándo será el momento ideal para volver a entrenar.',
                  style: TextStyle(color: AppColors.text),
                )
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.primary)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: .symmetric(horizontal: 20)
                ),
                onPressed: () async {
                  await context.read<MuscleFatigueProvider>().set(fatiguedMuscle.muscleId, value);

                  if(!context.mounted) return;

                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}