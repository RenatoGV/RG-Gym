import 'package:flutter/material.dart';
import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/models/muscle_group.dart';

class FatiguedMuscle {
  final int muscleId;
  final double fatigued;
  final DateTime updatedAt;

  const FatiguedMuscle({
    required this.muscleId,
    required this.fatigued,
    required this.updatedAt
  });

  factory FatiguedMuscle.fromJson(Map<String, dynamic> json) {
    return FatiguedMuscle(
      muscleId: json['muscleId'] as int,
      fatigued: (json['fatigued'] as num).toDouble(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'muscleId': muscleId,
      'fatigued': fatigued,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  FatigueState get state => switch(fatigued) {
    <= 0.15 => .weakened,
    <= 0.4 => .recovered,
    <= 0.7 => .recovering,
    _ => .fatigued
  };

  Color get stateColor => switch(state) {
    .weakened => Colors.green,
    .recovered => Colors.blue,
    .recovering => Colors.amber,
    .fatigued => Colors.red
  };

  MuscleGroup get muscle => muscleGroups.firstWhere((e) => e.id == muscleId);
}

enum FatigueState {
  weakened,
  recovered,
  recovering,
  fatigued
}