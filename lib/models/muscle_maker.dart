class MuscleMarker {
  final int muscleId;
  final String name;
  final double x;
  final double y;
  final MarkerPosition position;

  const MuscleMarker({
    required this.muscleId,
    required this.name,
    required this.x,
    required this.y,
    required this.position
  });
}

enum MarkerPosition {
  left,
  right,
  floating
}