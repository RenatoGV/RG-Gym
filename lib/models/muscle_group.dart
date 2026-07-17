class MuscleGroup {
  final int id;
  final String name;
  final MuscleType? type;


  const MuscleGroup({
    required this.id,
    required this.name,
    this.type
  });
}

enum MuscleType {
  front,
  back,
}