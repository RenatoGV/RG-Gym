import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/routine.dart';
import 'package:rg_gym/providers/routines_provider.dart';
import 'package:rg_gym/screens/tabs/routines/widgets/routine_item.dart';
import 'package:rg_gym/service/routine_export.dart';
import 'package:rg_gym/shared/app_bar.dart';
import 'package:rg_gym/shared/widgets/fixed_line_formatter.dart';
import 'package:uuid/uuid.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routines = context.watch<RoutinesProvider>().routines;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Mis Entrenamientos",
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: const Text(
              "Crea tus propias rutinas de ejercicios",
              style: TextStyle(color: AppColors.text),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  "Mis Rutinas",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () async {
                    await showRoutineDialog(context);
                  },
                  child: const Text(
                    "Agregar",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                
                return RoutineItem(
                  routine: routine,
                  onEdit: () async {
                    await showRoutineDialog(
                      context,
                      routine: routine
                    );
                  },
                  onDuplicate: () async => await context.read<RoutinesProvider>().duplicate(routine),
                  onDelete: () async => await context.read<RoutinesProvider>().remove(routine.id),
                );
              },
            ),
          )
        ],
      )
    );
  }
}

Future<bool?> showRoutineDialog(BuildContext context, { Routine? routine }) {
  final nameController = TextEditingController(text: routine?.name ?? '');
  final commentController = TextEditingController(text: routine?.comment ?? '');

  return showDialog<bool>(
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
                  routine == null ? 'Nueva Rutina' : 'Editar Rutina',
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
                    labelText: "Nombre",
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

                const SizedBox(height: 20),

                TextField(
                  controller: commentController,
                  cursorColor: AppColors.primary,
                  maxLengthEnforcement: .enforced,
                  maxLines: 2,
                  minLines: 1,
                  inputFormatters: [FixedLineFormatter(charsPerLine: 30, maxLines: 2)],
                  decoration: const InputDecoration(
                    labelText: "Comentario",
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
                        final comment = commentController.text.trim();

                        if (name.isEmpty) return;

                        Routine newRoutine = Routine(
                          id: routine == null ? const Uuid().v4() : routine.id,
                          name: name,
                          comment: comment,
                          workouts: routine?.workouts
                        );

                        if (routine == null) {
                          await context.read<RoutinesProvider>().add(newRoutine);
                        } else {
                          await context.read<RoutinesProvider>().update(newRoutine);
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

void _showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Configuración'),

            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text('Exportar rutinas'),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _exportRoutines(context);
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Importar rutinas'),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _importRoutines(context);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _exportRoutines(BuildContext context) async {
  try {
    final routines = context.read<RoutinesProvider>().routines;

    await RoutineExport.exportRoutines(routines);
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al exportar rutinas: $e'),
      ),
    );
  }
}

Future<void> _importRoutines(BuildContext context) async {
  try {
    final routines = await RoutineExport.importRoutines();

    if (routines == null) return;

    if (!context.mounted) return;

    await context.read<RoutinesProvider>().importRoutines(routines);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rutinas importadas correctamente'),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al importar rutinas: $e'),
      ),
    );
  }
}