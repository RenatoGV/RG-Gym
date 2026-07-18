import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/models/workout.dart';
import 'package:rg_gym/providers/workout_session_provider.dart';
import 'package:rg_gym/screens/tabs/routines/widgets/execution_exercise_item.dart';
import 'package:rg_gym/screens/tabs/routines/widgets/execution_set_item.dart';
import 'package:rg_gym/service/workout_notification.dart';
import 'package:rg_gym/service/workout_session_manager.dart';
import 'package:rg_gym/shared/app_bar.dart';

class Execution extends StatefulWidget {
  final Workout workout;

  const Execution({
    super.key,
    required this.workout
  });

  @override
  State<Execution> createState() => _ExecutionState();
}

class _ExecutionState extends State<Execution> with WidgetsBindingObserver {
  late WorkoutSessionProvider _sessionProvider;
  bool _workoutStarted = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == .resumed) {
      WorkoutNotification.cancelRestFinishedNotification();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionProvider = context.read<WorkoutSessionProvider>();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sessionProvider.startWorkout(widget.workout);

      if(mounted) {
        setState(() {
          _workoutStarted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<WorkoutSessionProvider>().session;

    if (!_workoutStarted) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });

      return const SizedBox.shrink();
    }

    final Exercise currentExercise = exercises.firstWhere((e) => e.id == session.currentExercise.exercise);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        await _confirmExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: widget.workout.name,
          onBack: _confirmExit
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const .symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const SizedBox(height: 20),
                    Text('Ejercicio ${session.currentExerciseNumber}/${session.workout.trainingExercises!.length}', style: TextStyle(color: AppColors.primary, fontWeight: .bold)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                currentExercise.name,
                                maxLines: 2,
                                style: TextStyle(fontSize: 20, fontWeight: .w900),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                [...currentExercise.primaryMuscles, ...currentExercise.secondaryMuscles]
                                  .map((id) => muscleGroups.firstWhere((m) => m.id == id).name).join(', '),
                                style: TextStyle(color: AppColors.text),
                              )
                            ],
                          )
                        ),
                        IconButton(
                          onPressed: () => {
                            session.pause(),
                            
                            Navigator.pushNamed(
                              context,
                              '/exercise/info',
                              arguments: currentExercise,
                            )
                          },
                          icon: Icon(Icons.info_outline, color: Colors.white),
                        )
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
                              currentExercise.gif,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (session.currentExercise.note != null && session.currentExercise.note!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        width: .infinity,
                        child: Text(session.currentExercise.note!)
                      ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: session.currentExercise.sets.length,
                      itemBuilder: (context, index) {
                        bool isLast = index == session.currentExercise.sets.length - 1;
                        bool isCurrentSet = index ==  session.setIndex && session.phase == .execution;
                        bool isCompleted = index < session.setIndex || (index == session.setIndex && session.phase == .rest) || session.phase == .finished;

                        return ExecutionSetItem(
                          index: index + 1,
                          type: session.currentExercise.type,
                          set: session.currentExercise.sets[index],
                          isLast: isLast,
                          isCurrentSet: isCurrentSet,
                          isCompleted: isCompleted
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Lista de ejercicios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.backgroundSecondary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: session.workout.trainingExercises!.length,
                        itemBuilder: (context, index) {
                          final trainingExercise = session.workout.trainingExercises![index];

                          return ExecutionExerciseItem(
                            index: index,
                            trainingExercise: trainingExercise,
                            isNextExercise: session.isNextExercise(trainingExercise),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 300)
                  ]
                ),
              ),
              Align(
                alignment: .bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                  ),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      const SizedBox(height: 15),
                      _header(session),
                      const SizedBox(height: 15),
                      _counter(session),
                      const SizedBox(height: 15),
                      _buttons(session),
                      const SizedBox(height: 15)
                    ]
                  ),
                )
              )
            ],
          )
        )
      )
    );
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Salir del entrenamiento?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
          content: const Text('Si sales ahora, el entrenamiento actual se perderá.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar', style: TextStyle(color: AppColors.primary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Salir'),
            )
          ],
        );
      },
    );

    if (shouldExit == true && mounted) {
      await _sessionProvider.finishWorkout();
    }
  }
}

Widget _header(WorkoutSessionManager session) {
  return Center(
      child: Text(phaseTitle(session.phase), style: TextStyle(color: AppColors.primary, fontSize: 40, fontWeight: .bold))
  );
}

Widget _counter(WorkoutSessionManager session) {
  return Padding(
    padding: .symmetric(horizontal: 40),
    child: Row(
      children: [
        SizedBox(
          width: 48,
          child: session.phase == .preparation || session.phase == .rest ?
            IconButton(
              onPressed: () => session.addTimeToTimer(),
              icon: SvgPicture.asset(
                'assets/icons/15.svg',
              )
            ) :
            null,
        ),
        Expanded(
          child: Center(
            child: AutoSizeText(
              session.remainingText,
              minFontSize: 60,
              maxLines: 1,
              style: TextStyle(fontWeight: .bold)
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: session.phase != .finished ?
            IconButton(
              onPressed: () => session.isPaused ? session.resume() : session.pause(),
              icon: Icon(
                session.isPaused ? Icons.play_arrow_rounded: Icons.pause_rounded,
                color: AppColors.text,
              ),
            ) :
            null,
        ),
      ],
    )
  );
}

Widget _buttons(WorkoutSessionManager session) {
  bool isStarting = session.phase == .preparation && session.exerciseIndex == 0 && session.setIndex == 0;

  return Padding(
    padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
    child: Row(
      spacing: 30,
      children: [
        if(!isStarting)
          IconButton(
            onPressed: () => session.previous(),
            icon: Icon(Icons.arrow_back_ios_rounded)
          ),
        Expanded(
          child: FilledButton(
            onPressed: () => session.next(),
            child: Text(
              session.phase == .finished ? 'Terminar' : isStarting ? 'Comenzar' : 'Siguiente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ),
      ],
    )
  );
}

String phaseTitle(WorkoutPhase phase) {
  return switch(phase) {
    .preparation => 'Preparación',
    .execution => '¡Realiza el ejercicio!',
    .rest => 'Descanso',
    .finished => 'Finalizado',
  };
}