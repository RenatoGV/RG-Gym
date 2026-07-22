import 'package:flutter/material.dart';
import 'package:rg_gym/models/history_workout.dart';
import 'package:rg_gym/service/history_storage.dart';

class HistoryProvider extends ChangeNotifier {
  List<HistoryWorkout> _history = [];

  List<HistoryWorkout> get history => List.unmodifiable(_history);

  Future<void> load() async {
    _history = await HistoryStorage.getAll();
    notifyListeners();
  }

  Future<void> save() async {
    await HistoryStorage.saveAll(_history);
  }

  HistoryWorkout getById(String id) {
    return _history.firstWhere((e) => e.id == id);
  }

  Future<void> add(HistoryWorkout historyWorkout) async {
    _history.add(historyWorkout);
    notifyListeners();
    await save();
  }

  Future<void> update(HistoryWorkout historyWorkout) async {
    final index = _history.indexWhere((hw) => hw.id == historyWorkout.id);

    if(index == -1) throw Exception('History not found');

    _history[index] = historyWorkout;

    notifyListeners();
    await save();
  }

  Future<void> remove(String id) async {
    _history.removeWhere((hw) => hw.id == id);
    notifyListeners();
    await save();
  }
}