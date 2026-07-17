import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/data/weekdays.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/routine.dart';
import 'package:rg_gym/models/workout.dart';
import 'package:rg_gym/providers/routines_provider.dart';
import 'package:rg_gym/screens/tabs/routines/widgets/workout_item.dart';
import 'package:rg_gym/shared/app_bar.dart';
import 'package:uuid/uuid.dart';

class RoutineDetail extends StatelessWidget {
  const RoutineDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final routineId = ModalRoute.of(context)!.settings.arguments as String;
    Routine routine = context.select<RoutinesProvider, Routine>((provider) => provider.getById(routineId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: routine.name,
        bottom: (routine.comment != null && routine.comment!.isNotEmpty == true)
          ? PreferredSize(
            preferredSize: const Size.fromHeight(35),
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Text(
                routine.comment!,
                style: TextStyle(color: AppColors.text),
              ),
            ),
          ) : null
      ),
      body: (routine.workouts == null || routine.workouts!.isEmpty) ?
        const Center(
          child: Text(
            'No hay entrenamiento',
            textAlign: TextAlign.center,
          ),
        ) :
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                "Días de entrenamiento",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                itemCount: routine.workouts?.length ?? 0,
                itemBuilder: (context, index) {
                  final workout = routine.workouts![index];
                  
                  return WorkoutlItem(
                    routineId: routine.id,
                    workout: workout,
                    onEdit: () async {
                      await showWorkoutDialog(
                        context,
                        routineId: routine.id,
                        workout: workout
                      );
                    },
                    onDuplicate: () async => await context.read<RoutinesProvider>().duplicateWorkout(routineId, workout),
                    onDelete: () async => await context.read<RoutinesProvider>().removeWorkout(routineId, workout.id),
                  );
                },
              ),
            )
          ],
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showWorkoutDialog(context, routineId: routine.id);
        },
        label: Text('Agregar', style: TextStyle(fontWeight: FontWeight.w900)),
        icon: Icon(Icons.add, fontWeight: FontWeight.w900),
      ),
    );
  }
}

Future<bool?> showWorkoutDialog(BuildContext context, { required String routineId, Workout? workout }) {
  final nameController = TextEditingController(text: workout?.name ?? '');
  List<String> selectedDays = workout?.days ?? [];

  return showDialog<bool>(
    context: context,
    builder:(context) {
      return StatefulBuilder(
        builder: (context, setState) {
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
                    const Text(
                      "Añadir entrenamiento",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: nameController,
                      cursorColor: AppColors.primary,
                      decoration: const InputDecoration(
                        labelText: "Nombre del entrenamiento",
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
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Días de entrenamiento',
                      style: TextStyle(color: AppColors.primary, fontWeight: .bold),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekdays.map((day) {
                        return Expanded(
                          child: Column(
                            children: [
                              Text(
                                day.name.substring(0, 3),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Checkbox(
                                value: selectedDays.contains(day.key),
                                checkColor: Colors.white,
                                activeColor: AppColors.primary,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked!) {
                                      selectedDays.add(day.key);
                                    } else {
                                      selectedDays.remove(day.key);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
                            final name = nameController.text.trim();

                            if (name.isEmpty) {
                              return;
                            }

                            final orderedDays = weekdays
                              .toList()
                              .where((day) => selectedDays.contains(day.key))
                              .map((day) => day.key)
                              .toList();

                            final Workout newWorkout = Workout(
                              id: workout == null ? const Uuid().v4() : workout.id,
                              name: name,
                              days: orderedDays,
                              trainingExercises: workout?.trainingExercises
                            );

                            if(workout == null) {
                              await context.read<RoutinesProvider>().addWorkout(routineId, newWorkout);
                            } else {
                              await context.read<RoutinesProvider>().updateWorkout(routineId, newWorkout);
                            }

                            if (!context.mounted) return;

                            Navigator.pop(context, true);
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
  );
}