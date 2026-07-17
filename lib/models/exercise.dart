class Exercise {
  final int id;
  final String name;
  final String gif;
  final String preparation;
  final List<String> execution;
  final List<String> details;
  final List<int> primaryMuscles;
  final List<int> secondaryMuscles;
  final List<int> equipment;

  const Exercise({
    required this.id,
    required this.name,
    required this.gif,
    required this.preparation,
    required this.execution,
    required this.details,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment
  });
}