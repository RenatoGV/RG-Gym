import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/training_exercise.dart';
import 'package:rg_gym/providers/routines_provider.dart';
import 'package:rg_gym/screens/tabs/routines/widgets/training_set_item.dart';
import 'package:rg_gym/shared/app_bar.dart';
import 'package:rg_gym/shared/widgets/fixed_line_formatter.dart';
import 'package:rg_gym/shared/widgets/fixed_null_formatter.dart';

class ExerciseDetail extends StatefulWidget {
  const ExerciseDetail({super.key});

  @override
  State<ExerciseDetail> createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  bool _loaded = false;

  String? routineId;
  String? workoutId;
  String? trainingExerciseId;

  TrainingExercise? editableTrainingExercise;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;
    _loaded = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    routineId = args['routineId'];
    workoutId = args['workoutId'];
    trainingExerciseId = args['trainingExerciseId'];

    final trainingExercise = context.read<RoutinesProvider>().getTrainingExerciseById(routineId!, workoutId!, trainingExerciseId!);

    editableTrainingExercise = trainingExercise.clone();
  }

  void _updateTrainingType () {
    switch(editableTrainingExercise!.type) {
      case .repsWeight:
        editableTrainingExercise!.sets = [TrainingSet(reps: 0, weight: 0, time: null), TrainingSet(reps: 0, weight: 0, time: null), TrainingSet(reps: 0, weight: 0, time: null)];
        break;
      case .reps:
        editableTrainingExercise!.sets = [TrainingSet(reps: 0, weight: null, time: null), TrainingSet(reps: 0, weight: null, time: null), TrainingSet(reps: 0, weight: null, time: null)];
        break;
      case .weight:
        editableTrainingExercise!.sets = [TrainingSet(reps: null, weight: 0, time: null), TrainingSet(reps: null, weight: 0, time: null), TrainingSet(reps: null, weight: 0, time: null)];
        break;
      case .time:
        editableTrainingExercise!.sets = [TrainingSet(reps: null, weight: null, time: Duration(minutes: 0)), TrainingSet(reps: null, weight: null, time: Duration(minutes: 0)), TrainingSet(reps: null, weight: null, time: Duration(minutes: 0))];
        break;
    }
  }

  void _propagateReps(int fromIndex, int value) {
    final sets = editableTrainingExercise!.sets;

    setState(() {
      for (int i = fromIndex; i < sets.length; i++) {
        sets[i].reps = value;
      }
    });
  }

  void _propagateWeight(int fromIndex, double value) {
    final sets = editableTrainingExercise!.sets;

    setState(() {
      for (int i = fromIndex; i < sets.length; i++) {
        sets[i].weight = value;
      }
    });
  }

  void _propagateTime(int fromIndex, Duration value) {
    final sets = editableTrainingExercise!.sets;

    setState(() {
      for (int i = fromIndex; i < sets.length; i++) {
        sets[i].time = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainingExercise = editableTrainingExercise!;
    final exercise = exercises.firstWhere((e) => e.id == trainingExercise.exercise);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Editar ejercicio',
        background: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const .symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: .center,
              children: [
                ClipRRect(
                  borderRadius: .circular(8),
                  child: Image.asset(
                    exercise.gif,
                    width: 100,
                    height: 100,
                    fit: .cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: .bold
                        )
                      ),
                      SizedBox(height: 8),
                      Text(
                        [...exercise.primaryMuscles, ...exercise.secondaryMuscles]
                          .map((id) => muscleGroups.firstWhere((m) => m.id == id).name).join(', '),
                        style: TextStyle(color: AppColors.text),
                      )
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                    Navigator.pushNamed(
                      context,
                      '/exercise/info',
                      arguments: exercise,
                    ),
                  icon: const Icon(Icons.info_outline),
                )
              ],
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                _buildTypes(trainingExercise),

                const Spacer(),

                FilledButton(
                  onPressed: () async {
                    final result = await showRestTimeDialog(context, initialValue: Duration(seconds: trainingExercise.restTime));
                    
                    if(result != null) {
                      setState(() {
                        trainingExercise.restTime = result.inSeconds;
                      });
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    backgroundColor: AppColors.backgroundSecondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  ),
                  child: Row(
                    spacing: 2,
                    children: [
                      Icon(Icons.timer_outlined),
                      Text(
                        '${Duration(seconds: trainingExercise.restTime).inMinutes}:'
                        '${(trainingExercise.restTime % 60).toString().padLeft(2, '0')}',
                      )
                    ],
                  ),
                ),

                const Spacer(),

                FilledButton(
                  onPressed: trainingExercise.note == null
                    ? () async {
                        final result = await showNoteDialog(context);

                        if (result != null) {
                          setState(() {
                            trainingExercise.note = result;
                          });
                        }
                      }
                    : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    backgroundColor: AppColors.backgroundSecondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: Colors.grey.shade700,
                    disabledForegroundColor: Colors.grey.shade400,
                  ),
                  child: Row(
                    spacing: 2,
                    children: [
                      Icon(Icons.add),
                      Text('Nota')
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            if (trainingExercise.note != null && trainingExercise.note!.isNotEmpty)
              SizedBox(
                width: .infinity,
                child: FilledButton(
                  onPressed: () async {
                    final result = await showNoteDialog(context, note: trainingExercise.note);

                    if(result != null) {
                      setState(() {
                        trainingExercise.note = (result.isNotEmpty) ? result : null;
                      });
                    }
                  },
                  style: FilledButton.styleFrom(
                    alignment: .centerStart,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    backgroundColor: AppColors.backgroundSecondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(trainingExercise.note!)
                ),
              ),

            const SizedBox(height: 30),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trainingExercise.sets.length + 1,
              itemBuilder: (context, index) {
                if (index == trainingExercise.sets.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          trainingExercise.sets.add(trainingExercise.sets.last);
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
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
                              "Añadir serie",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                bool isLast = index == trainingExercise.sets.length - 1;

                return TrainingSetItem(
                  index: index + 1,
                  type: trainingExercise.type,
                  set: trainingExercise.sets[index],
                  isLast: isLast,
                  onDelete: () {
                    if(trainingExercise.sets.length == 1) return;

                    setState(() {
                      trainingExercise.sets.removeAt(index);
                    });
                  },
                  onRepsChanged: (value) => _propagateReps(index, value),
                  onWeightChanged: (value) => _propagateWeight(index, value),
                  onTimeChanged: (value) => _propagateTime(index, value),
                );
              },
            ),
            const SizedBox(height: 200)
          ]
        )
      ),
      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: Padding(
          padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: SizedBox(
            width: .infinity,
            height: 55,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary
              ),
              label: Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: .bold)),
              onPressed: () async {
                await context.read<RoutinesProvider>().updateTrainingExercise(routineId!, workoutId!, trainingExercise);

                if (!context.mounted) return;

                Navigator.pop(context);
              }
            ),
          ),
        ),
    );
  }

  Widget _buildTypes(TrainingExercise trainingExercise) {
    return Container(
      width: 180,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<TrainingType>(
        onSelected: (value) {
          if(trainingExercise.type == value) return;
          setState(() {
            trainingExercise.type = value;
            _updateTrainingType();
          });
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: TrainingType.repsWeight,
            child: Text('Repeticiones y peso'),
          ),
          PopupMenuItem(
            value: TrainingType.reps,
            child: Text('Repeticiones'),
          ),
          PopupMenuItem(
            value: TrainingType.weight,
            child: Text('Peso'),
          ),
          PopupMenuItem(
            value: TrainingType.time,
            child: Text('Tiempo'),
          )
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              switch (trainingExercise.type) {
                TrainingType.repsWeight => 'Repeticiones y peso',
                TrainingType.reps => 'Repeticiones',
                TrainingType.weight => 'Peso',
                TrainingType.time => 'Tiempo',
              },
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      )
    );
  }
}

Future<Duration?> showRestTimeDialog(BuildContext context, { Duration? initialValue }) {
  final minutesController = TextEditingController(text: initialValue?.inMinutes.toString() ?? '00');
  final secondsController = TextEditingController(text: initialValue == null ? '00' : (initialValue.inSeconds % 60).toString().padLeft(2, '0'));

  return showDialog<Duration>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiempo de descanso',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        enableInteractiveSelection: false,
                        textAlign: .center,
                        controller: minutesController,
                        cursorColor: AppColors.primary,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        inputFormatters: [
                          FixedNullFormatter()
                        ],
                        decoration: const InputDecoration(
                          counterText: '',
                          labelText: '',
                          floatingLabelStyle: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.backgroundSecondary,
                              width: 2,
                            )
                          )
                        ),
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Text(
                      ":",
                      style: TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: TextField(
                        enableInteractiveSelection: false,
                        textAlign: .center,
                        controller: secondsController,
                        cursorColor: AppColors.primary,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        inputFormatters: [
                          FixedNullFormatter()
                        ],
                        decoration: const InputDecoration(
                          counterText: '',
                          labelText: '',
                          floatingLabelStyle: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.backgroundSecondary,
                              width: 2,
                            )
                          )
                        ),
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      const Text('Minutos', style: TextStyle(color: AppColors.text)),
                      const Text('Segundos', style: TextStyle(color: AppColors.text)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),

                    const SizedBox(width: 12),

                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 45),
                      ),
                      onPressed: () async {
                        final int minutes = int.tryParse(minutesController.text.trim()) ?? 0;
                        final int seconds = int.tryParse(secondsController.text.trim()) ?? 0;

                        Duration result = Duration(minutes: minutes, seconds: seconds);

                        if (!context.mounted) return;

                        Navigator.pop(context, result);
                      },
                      child: const Text("Guardar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  );
}

Future<String?> showNoteDialog(BuildContext context, { String? note }) {
  final noteController = TextEditingController(text: note ?? '');

  return showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: 700,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note == null ? 'Agregar Nota' : 'Editar Nota',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  textCapitalization: .sentences,
                  controller: noteController,
                  cursorColor: AppColors.primary,
                  maxLengthEnforcement: .enforced,
                  maxLines: 4,
                  minLines: 1,
                  inputFormatters: [FixedLineFormatter(charsPerLine: 30, maxLines: 4)],
                  decoration: const InputDecoration(
                    labelText: "Nota",
                    alignLabelWithHint: true,
                    floatingLabelStyle: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.backgroundSecondary,
                        width: 2,
                      )
                    )
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (note != null && note.isNotEmpty)
                      TextButton(
                        onPressed: () => Navigator.pop(context, ''),
                        child: const Text(
                          "Limpiar",
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),

                    const Spacer(),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),

                    const SizedBox(width: 12),

                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 45),
                      ),
                      onPressed: () async {
                        final note = (noteController.text.trim().isEmpty) ? null : noteController.text.trim();

                        if (!context.mounted) return;

                        Navigator.pop(context, note);
                      },
                      child: const Text("Guardar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  );
}