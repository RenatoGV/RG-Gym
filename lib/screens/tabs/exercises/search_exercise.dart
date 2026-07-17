import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_gym/config/data/equipments.dart';
import 'package:rg_gym/config/data/exercises.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/helpers/search_helper.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/models/workout.dart';
import 'package:rg_gym/providers/routines_provider.dart';
import 'package:rg_gym/screens/tabs/exercises/widgets/exercise_card.dart';
import 'package:rg_gym/screens/tabs/exercises/widgets/exercise_list_tile.dart';
import 'package:rg_gym/service/favorites_storage.dart';
import 'package:rg_gym/shared/app_bar.dart';

enum SortType {
  relevance,
  alphabetical
}

enum ExerciseFilter {
  all,
  favorites,
}

const muscleSections = {
  "Frente": [1, 4, 5],
  "Espalda": [9, 11, 12],
  "Brazos": [0, 2, 3, 10],
  "Piernas": [6, 7, 8, 13, 14, 15],
  "Cardio": [16],
};

class SearchExercise extends StatefulWidget {
  const SearchExercise({ super.key });

  @override
  State<SearchExercise> createState() => _SearchExerciseState();
}

class _SearchExerciseState extends State<SearchExercise> {
  String? routineId;
  Workout? workout;
  bool _loaded = false;
  bool gridded = true;
  List<int> selectedMuscles = [];
  List<int> selectedEquipment = [];
  List<int> selectedExercises = [];

  final TextEditingController searchController = TextEditingController();
  final searchFocus = FocusNode();
  late List<Exercise> filteredExercises;

  SortType sortType = SortType.relevance;
  ExerciseFilter exerciseFilter = ExerciseFilter.all;

  @override
  void initState() {
    super.initState();
    filteredExercises = [];
    searchController.addListener(_applyFilters);
    _applyFilters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;
    _loaded = true;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final muscleId = args?['muscleId'] as int?;
    final searching = args?['searching'] as bool? ?? false;

    setState(() {
      routineId = args?['routineId'] as String?;
      workout = args?['workout'] as Workout?;
    });
    
    if (muscleId != null) {
      selectedMuscles.add(muscleId);
    }

    _applyFilters();

    if (searching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() async {
    final search = SearchHelper.normalize(searchController.text.trim().toLowerCase());
    final selectedMusclesFilter = selectedMuscles.toSet();
    final selectedEquipments = selectedEquipment.toSet();

    final searchedMuscles = muscleGroups
      .where((m) => SearchHelper.normalize(m.name).contains(search))
      .map((m) => m.id)
      .toSet();

    final searchedEquipments = equipments
      .where((e) => SearchHelper.normalize(e.name).contains(search))
      .map((e) => e.id)
      .toSet();

    final favorites = exerciseFilter == ExerciseFilter.favorites
      ? (await FavoritesStorage.getAll()).toSet()
      : <int>{};

    List<Exercise> list = exercises.where((exercise) {
      final byName = search.isEmpty || SearchHelper.normalize(exercise.name).contains(search);

      final byMuscle = searchedMuscles.isNotEmpty && (exercise.primaryMuscles.any(searchedMuscles.contains) || exercise.secondaryMuscles.any(searchedMuscles.contains));

      final byEquipment = searchedEquipments.isNotEmpty && (exercise.equipment.any(searchedEquipments.contains));

      final bySelectedMuscles = selectedMusclesFilter.isEmpty ||
        exercise.primaryMuscles.any(selectedMusclesFilter.contains) ||
        exercise.secondaryMuscles.any(selectedMusclesFilter.contains);

      final byEquipments = selectedEquipment.isEmpty ||
        exercise.equipment.any(selectedEquipments.contains);

      final matchesSearch = search.isEmpty || byName || byMuscle || byEquipment;

      final matchesFavorite = exerciseFilter == ExerciseFilter.all || favorites.contains(exercise.id);

      return matchesSearch && matchesFavorite && bySelectedMuscles && byEquipments;
    }).toList();

    switch (sortType) {
      case SortType.relevance:
        list.sort((a, b) => a.id.compareTo(b.id));
        break;

      case SortType.alphabetical:
        list.sort((a, b) => SearchHelper.normalize(a.name).compareTo(SearchHelper.normalize(b.name)));
        break;
    }

    if (!mounted) return;

    setState(() {
      filteredExercises = list;
    });
  }

  final musclesById = {
    for (final m in muscleGroups) m.id: m,
  };

  void _toggleExercise(int id) {
    setState(() {
      if(selectedExercises.contains(id)) {
        selectedExercises.remove(id);
      } else {
        selectedExercises.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Buscar Ejercicios",
        background: AppColors.background,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: Padding(
            padding: const EdgeInsetsGeometry.only(left: 20, right: 20, top: 0, bottom: 15),
            child: SizedBox(
              height: 47,
              child: TextField(
                controller: searchController,
                focusNode: searchFocus,
                cursorColor: Colors.white,
                
                decoration: InputDecoration(
                  hintText: 'Buscar',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.backgroundSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: .none
                  )
                ),
              ),
            ),
          )
        )
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            _buildFilters(),

            const SizedBox(height: 20),

            _buildSortBar(),

            const SizedBox(height: 20),

            Expanded(
              child: gridded ? GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridded ? 2 : 1,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  mainAxisExtent: 220,
                ),
                itemCount: filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];

                  return ExerciseCard(
                    key: ValueKey(exercise.id),
                    exercise: exercise,
                    selected: selectedExercises.contains(exercise.id),
                    onTap: workout != (null)
                      ? () => _toggleExercise(exercise.id)
                      : () => Navigator.pushNamed(
                        context,
                        '/exercise/info',
                        arguments: exercise,
                      ),
                  );
                }
              ) : ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: filteredExercises.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];

                  return ExerciseListTile(
                    key: ValueKey(exercise.id),
                    exercise: exercise,
                    selected: selectedExercises.contains(exercise.id),
                    onTap: workout != (null)
                      ? () => _toggleExercise(exercise.id)
                      : () => Navigator.pushNamed(
                        context,
                        '/exercise/info',
                        arguments: exercise,
                      ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: selectedExercises.isEmpty
        ? null
        : Padding(
          padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: SizedBox(
            width: .infinity,
            height: 55,
            child: FilledButton.icon(
              label: Text('Agregar ${selectedExercises.length} ejercicio${(selectedExercises.length > 1) ? 's' : ''}', style: TextStyle(fontWeight: .bold)),
              onPressed: () async {
                await context.read<RoutinesProvider>().addTrainingExercises(routineId!, workout!, selectedExercises);

                if (!context.mounted) return;

                Navigator.of(context)..pop()..pop();
              }
            ),
          ),
        )
    );
  }

  Widget _buildSortBar() {
    return Row(
      children: [
        PopupMenuButton<SortType>(
          onSelected: (value) {
            setState(() {
              sortType = value;
              _applyFilters();
            });
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: SortType.relevance,
              child: Text('Relevancia'),
            ),
            PopupMenuItem(
              value: SortType.alphabetical,
              child: Text('Alfabético'),
            )
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sortType == SortType.relevance
                    ? "Relevancia"
                    : "Alfabético",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            setState(() {
              gridded = !gridded;
            });
          },
          icon: Icon(
            gridded ? Icons.view_list_rounded : Icons.grid_view_rounded,
          ),
        )
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: () async {
              final result = await showFiltersBottomSheet(context);

              if (result == null) return;

              exerciseFilter = result;
              await _applyFilters();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )
            ),
            child: Text(exerciseFilter == ExerciseFilter.all ? 'Todos' : 'Favoritos',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white)
            ),
          )
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: FilledButton(
            onPressed: () async {
              final result = await showMuscleGroupsBottomSheet(context,
                selectedMuscles: selectedMuscles,
              );

              if (result != null) {
                setState(() {
                  selectedMuscles = result;
                  _applyFilters();
                });
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: (selectedMuscles.isEmpty) ? Colors.transparent : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.primary),
              )
            ),
            child: Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    'Grupos musculares',
                    maxLines: 1,
                    minFontSize: 8,
                    stepGranularity: 1,
                    textAlign: .center,
                    style: TextStyle(
                      color: selectedMuscles.isEmpty
                          ? AppColors.primary
                          : Colors.white,
                    ),
                  ),
                ),
                if (selectedMuscles.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.white,
                    child: Text(
                      '${selectedMuscles.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: () async {
              final result = await showEquipmentBottomSheet(context,
                selectedEquipment: selectedEquipment,
              );

              if (result != null) {
                setState(() {
                  selectedEquipment = result;
                  _applyFilters();
                });
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: (selectedEquipment.isEmpty) ? Colors.transparent : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.primary),
              )
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                Text(
                  'Equipo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: (selectedEquipment.isEmpty) ? AppColors.primary : Colors.white)),
                if (selectedEquipment.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 9,
                    child: Text(
                      selectedEquipment.length.toString(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<ExerciseFilter?> showFiltersBottomSheet(BuildContext context) async {
    ExerciseFilter selected = exerciseFilter;

    return showModalBottomSheet<ExerciseFilter>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: RadioGroup<ExerciseFilter>(
                groupValue: selected,
                onChanged: (value) {
                  setModalState(() {
                    selected = value!;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Filtros',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Builder(
                      builder: (context) => _filterTile(
                        context: context,
                        value: ExerciseFilter.all,
                        icon: Icons.fitness_center,
                        text: "Todos los ejercicios",
                      ),
                    ),

                    Builder(
                      builder: (context) => _filterTile(
                        context: context,
                        value: ExerciseFilter.favorites,
                        icon: Icons.favorite,
                        text: "Favoritos",
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: EdgeInsetsGeometry.only(left: 10, right: 10, bottom: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, selected),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            )
                          ),
                          child: const Text(
                            'Aplicar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterTile({
    required BuildContext context,
    required ExerciseFilter value,
    required IconData icon,
    required String text,
  }) {
    return InkWell(
      onTap: () {
        RadioGroup.maybeOf<ExerciseFilter>(context)?.onChanged(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            Radio<ExerciseFilter>(
              fillColor: WidgetStatePropertyAll(AppColors.primary),
              value: value,
            ),
          ],
        ),
      ),
    );
  }

  Future<List<int>?> showMuscleGroupsBottomSheet(BuildContext context, { required List<int> selectedMuscles }) async {
    final selected = {...selectedMuscles};

    return await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      showDragHandle: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.95,
              minChildSize: 0.60,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),

                              const SizedBox(width: 4),

                              const Text(
                                "Grupos musculares",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Spacer(),

                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    selected.clear();
                                  });
                                },
                                child: Text('Limpiar', style: TextStyle(color: AppColors.primary))
                              )
                            ],
                          ),
                        ),

                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            children: muscleSections.entries.map((section) {

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                                    child: Text(
                                      section.key,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),

                                  ...section.value.map((id) {

                                    final muscle = musclesById[id]!;

                                    final checked = selected.contains(id);

                                    return CheckboxListTile(
                                      value: checked,
                                      controlAffinity: ListTileControlAffinity.leading,
                                      activeColor: AppColors.primary,
                                      checkColor: AppColors.background,
                                      title: Text(muscle.name),
                                      onChanged: (_) {
                                        setModalState(() {
                                          if (checked) {
                                            selected.remove(id);
                                          } else {
                                            selected.add(id);
                                          }
                                        });
                                      },
                                    );
                                  }),
                                ],
                              );
                            }).toList(),
                          ),
                        ),

                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    selected.toList(),
                                  );
                                },
                                child: const Text("Aplicar"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<int>?> showEquipmentBottomSheet(BuildContext context, { required List<int> selectedEquipment }) async {
    final selected = {...selectedEquipment};

    return await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      showDragHandle: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.95,
              minChildSize: 0.60,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),

                              const SizedBox(width: 4),

                              const Text(
                                "Equipo",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Spacer(),

                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    selected.clear();
                                  });
                                },
                                child: Text('Limpiar', style: TextStyle(color: AppColors.primary))
                              )
                            ],
                          ),
                        ),

                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: equipments.length,
                            itemBuilder: (context, index) {
                              final equipment = equipments[index];

                              final checked = selected.contains(equipment.id);

                              return CheckboxListTile(
                                checkColor: AppColors.background,
                                value: checked,
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: AppColors.primary,
                                title: Text(equipment.name),
                                onChanged: (_) {
                                  setModalState(() {
                                    if (checked) {
                                      selected.remove(equipment.id);
                                    } else {
                                      selected.add(equipment.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),

                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    selected.toList(),
                                  );
                                },
                                child: const Text("Aplicar"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}