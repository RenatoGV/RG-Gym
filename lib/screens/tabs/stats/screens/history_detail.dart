import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/format_helper.dart';
import 'package:rg_gym/models/history_workout.dart';
import 'package:rg_gym/providers/history_provider.dart';
import 'package:rg_gym/screens/tabs/stats/widgets/history_exercise_item.dart';
import 'package:rg_gym/shared/app_bar.dart';

class HistoryDetail extends StatelessWidget {
  final HistoryWorkout historyWorkout;

  const HistoryDetail({
    super.key,
    required this.historyWorkout
  });

  @override
  Widget build(BuildContext context) {
    final todayFormatted = DateFormat('d MMM yyyy', 'es').format(historyWorkout.date);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: historyWorkout.name,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  final navitagor = Navigator.of(context);
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: historyWorkout.date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    locale: const Locale('es', 'ES'),
                  );

                  if(selectedDate != null && context.mounted) {
                    await context.read<HistoryProvider>().modifyDate(historyWorkout.id, selectedDate);
                    navitagor.pop();
                  }
                  break;
                case 'delete':
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Eliminar registro', style: TextStyle(color: AppColors.primary, fontWeight: .bold)),
                      content: const Text('¿Estás seguro que deseas eliminar el registro?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );

                  if(confirmed == true && context.mounted) {
                    await context.read<HistoryProvider>().remove(historyWorkout.id);

                    if(context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text(
                  'Editar fecha de entremiento'
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Eliminar registro',
                  style: TextStyle(
                    color: AppColors.primary
                  ),
                ),
              )
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const .symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: .start,
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
                    Text(todayFormatted, style: TextStyle(color: AppColors.text))
                  ],
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
                            Text('${(historyWorkout.completedExercises.length / historyWorkout.trainingExercises!.length * 100).round()}', style: TextStyle(fontSize: 15, fontWeight: .w500)),
                            const Text('%', style: TextStyle(fontSize: 10, fontWeight: .w500)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: historyWorkout.completedExercises.length / historyWorkout.trainingExercises!.length,
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
                  _resumeBoxDetail('Ejercicios', '${historyWorkout.completedExercises.length}'),
                  const SizedBox(width: 5),
                  _resumeBoxDetail('Series', '${historyWorkout.completedSets}'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _resumeBoxDetail('Repeticiones', '${historyWorkout.completedReps}'),
                  const SizedBox(width: 5),
                  _resumeBoxDetail('Carga', '${FormatHelper.formatDouble(historyWorkout.totalWeight)} kg'),
                ],
              ),

              const SizedBox(height: 30),

              const Text("Hora", style: TextStyle(fontSize: 16, fontWeight: .w600)),
              const SizedBox(height: 10),
              _timeStat(historyWorkout.executionDuration, historyWorkout.restDuration, historyWorkout.preparationDuration),

              const SizedBox(height: 30),

              const Text("Ejercicios realizados", style: TextStyle(fontSize: 16, fontWeight: .w600)),
              const SizedBox(height: 10),
              Column(
                children: List.generate(
                  historyWorkout.trainingExercises!.length,
                  (index) {
                    final historyExercise = historyWorkout.trainingExercises![index];

                    return Padding(
                      padding: .only(bottom: index == historyWorkout.trainingExercises!.length - 1 ? 0 : 10),
                      child: HistoryExerciseItem(
                        historyExercise: historyExercise,
                      )
                    );
                  }
                ),
              ),

              if(historyWorkout.muscleFatigue.isNotEmpty)
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    const SizedBox(height: 30),
                    const Text("Músculos entrenados", style: TextStyle(fontSize: 16, fontWeight: .w600)),
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

                                      ...historyWorkout.musclesWorked
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

                                const SizedBox(width: 50),

                                Expanded(
                                  child: Stack(
                                    alignment: .center,
                                    children: [
                                      Image.asset(
                                        'assets/images/tras_base.png',
                                        fit: BoxFit.contain,
                                      ),

                                      ...historyWorkout.musclesWorked
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
                            historyWorkout.musclesWorkedString,
                            style: TextStyle(color: AppColors.text),
                            textAlign: .center,
                          ),
                        ]
                      )
                    ),
                  ],
                ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      )
    );
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