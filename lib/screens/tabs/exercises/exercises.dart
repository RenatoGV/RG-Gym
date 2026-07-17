import 'package:flutter/material.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/muscle_maker.dart';
import 'package:rg_gym/models/workout.dart';
import 'package:rg_gym/screens/tabs/exercises/widgets/muscle_hotspot.dart';
import 'package:rg_gym/shared/app_bar.dart';

class Exercises extends StatefulWidget {
  const Exercises({super.key});

  @override
  State<Exercises> createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  bool _loaded = false;
  bool front = true;
  List<MuscleMarker> markers = [];
  String? routineId;
  Workout? workout;

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }
  
  void loadMarkers() {
    markers = front ? frontMarkers : backMarkers;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;
    _loaded = true;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    setState(() {
      routineId = args?['routineId'] as String?;
      workout = args?['workout'] as Workout?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Ejercicios",
        background: AppColors.background,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/exercises/search', arguments: {'searching': true, 'routineId': routineId, 'workout': workout}),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.backgroundSecondary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      )
                    ),
                    child: Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(Icons.search),
                          SizedBox(width: 10),
                          Text('Buscar'),
                        ]
                      )
                    )
                  ),
                )
              )
        )
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 30),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: LayoutBuilder(
            key: ValueKey(front),
            builder: (context, constraints) {
              final imageWidth = constraints.maxWidth;
              final imageHeight = imageWidth * (front ? (896 / 500) : (873 / 500));

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: (details) {
                      const tapRadius = 18.0;

                      for (final marker in markers) {
                        final point = Offset(
                          marker.x * imageWidth,
                          marker.y * imageHeight,
                        );

                        if ((details.localPosition - point).distance <= tapRadius) {
                          Navigator.pushNamed(
                            context,
                            '/exercises/search',
                            arguments: {
                              'muscleId': marker.muscleId,
                              'routineId': routineId,
                              'workout': workout,
                            },
                          );
                          return;
                        }
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/${front ? 'frente_base_cut' : 'tras_base_cut'}.png',
                          fit: BoxFit.fill,
                        ),

                        ...markers.map(
                          (marker) => MuscleHotspot(
                            marker: marker,
                            imageWidth: imageWidth,
                            imageHeight: imageHeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            front = !front;
            loadMarkers();
          });
        },
        label: Text('Girar', style: TextStyle(fontWeight: FontWeight.w900)),
        icon: Icon(Icons.replay_outlined, fontWeight: FontWeight.w900),
      ),
    );
  }
}

const frontMarkers = <MuscleMarker>[
  MuscleMarker(
    name: "Hombros",
    muscleId: 0,
    x: .29,
    y: .25,
    position: .left,
  ),
  MuscleMarker(
    name: "Pectorales",
    muscleId: 1,
    x: .57,
    y: .27,
    position: .right,
  ),
  MuscleMarker(
    name: "Bíceps",
    muscleId: 2,
    x: .27,
    y: .34,
    position: .left,
  ),
  MuscleMarker(
    name: "Antebrazo",
    muscleId: 3,
    x: .76,
    y: .45,
    position: .right,
  ),
  MuscleMarker(
    name: "Abdomen",
    muscleId: 4,
    x: .499,
    y: .398,
    position: .right,
  ),
  MuscleMarker(
    name: "Oblicuos",
    muscleId: 5,
    x: .385,
    y: .41,
    position: .left,
  ),
  MuscleMarker(
    name: "Cuadriceps",
    muscleId: 6,
    x: .37,
    y: .68,
    position: .left,
  ),
  MuscleMarker(
    name: "Aductores",
    muscleId: 7,
    x: .53,
    y: .6,
    position: .right,
  ),
  MuscleMarker(
    name: "Abductores",
    muscleId: 8,
    x: .34,
    y: .52,
    position: .left,
  ),
  MuscleMarker(
    name: 'Cardio',
    muscleId: 16,
    x: .78,
    y: .7,
    position: .floating,
  ),
];

const backMarkers = <MuscleMarker>[
  MuscleMarker(
    name: "Trapecio",
    muscleId: 9,
    x: .58,
    y: .22,
    position: .right,
  ),
  MuscleMarker(
    name: "Tríceps",
    muscleId: 10,
    x: .28,
    y: .36,
    position: .left,
  ),
  MuscleMarker(
    name: "Dorsales",
    muscleId: 11,
    x: .6,
    y: .35,
    position: .right,
  ),
  MuscleMarker(
    name: "Lumbares",
    muscleId: 12,
    x: .5,
    y: .44,
    position: .left,
  ),
  MuscleMarker(
    name: "Glúteos",
    muscleId: 13,
    x: .57,
    y: .53,
    position: .right,
  ),
  MuscleMarker(
    name: "Isquiotibiales",
    muscleId: 14,
    x: .39,
    y: .65,
    position: .left,
  ),
  MuscleMarker(
    name: "Pantorillas",
    muscleId: 15,
    x: .35,
    y: .87,
    position: .left,
  ),
  MuscleMarker(
    name: 'Cardio',
    muscleId: 16,
    x: .78,
    y: .72,
    position: .floating,
  ),
];