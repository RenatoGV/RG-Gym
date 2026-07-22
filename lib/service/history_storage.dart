import 'dart:convert';

import 'package:rg_gym/models/history_workout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryStorage {
  static const _key = 'history';

  static Future<List<HistoryWorkout>> getAll() async {
    final sp = await SharedPreferences.getInstance();
    final data = sp.getStringList(_key) ?? [];

    return data
        .map((hw) => HistoryWorkout.fromJson(jsonDecode(hw)))
        .toList();
  }

  static Future<void> saveAll(List<HistoryWorkout> history) async {
    final sp = await SharedPreferences.getInstance();
    final data = history.map((hw) => jsonEncode(hw.toJson())).toList();

    await sp.setStringList(_key, data);
  }
}