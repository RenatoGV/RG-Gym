import 'package:flutter/material.dart';
import 'package:rg_gym/models/fatigued_muscle.dart';
import 'package:rg_gym/service/muscle_fatigue_storage.dart';

class MuscleFatigueProvider extends ChangeNotifier {
  List<FatiguedMuscle> _fatiguedMuscles = [];

  
  List<FatiguedMuscle> get fatiguedMuscles => List.unmodifiable(_fatiguedMuscles);
  
  Future<void> load() async {
    _fatiguedMuscles = await MuscleFatigueStorage.get();

    _recalculateFatigue();

    notifyListeners();
  }

  void _recalculateFatigue() {
    final now = DateTime.now();
    bool changed = false;

    for (var i = 0; i < _fatiguedMuscles.length; i++) {
      final muscle = _fatiguedMuscles[i];

      final recovered = now.difference(muscle.updatedAt).inSeconds * (0.25 / 86400);
      final current = (muscle.fatigued - recovered).clamp(0.0, 1.0);

      if(current != muscle.fatigued) {
        _fatiguedMuscles[i] = FatiguedMuscle(
          muscleId: muscle.muscleId,
          fatigued: current,
          updatedAt: now
        );

        changed = true;
      }
    }

    if(changed) save();
  }

  Future<void> save() async {
    await MuscleFatigueStorage.save(_fatiguedMuscles);
  }

  FatiguedMuscle getById(int id) {
    return _fatiguedMuscles.firstWhere((e) => e.muscleId == id);
  }

  Future<void> update(FatiguedMuscle fatiguedMuscle) async {
    final index = _fatiguedMuscles.indexWhere((e) => e.muscleId == fatiguedMuscle.muscleId);

    if(index == -1) throw Exception('Muscle not found');

    _fatiguedMuscles[index] = fatiguedMuscle;

    notifyListeners();
    await save();
  }

  Future<void> increase(int muscleId, double amount) async {
    final muscle = getById(muscleId);

    final updated = FatiguedMuscle(
      muscleId: muscle.muscleId,
      fatigued: (muscle.fatigued + amount).clamp(0.0, 1.0),
      updatedAt: DateTime.now()
    );

    await update(updated);
  }

  Future<void> set(int muscleId, double amount) async {
    final muscle = getById(muscleId);

    final updated = FatiguedMuscle(
      muscleId: muscle.muscleId,
      fatigued: amount,
      updatedAt: DateTime.now()
    );

    await update(updated);
  }
}