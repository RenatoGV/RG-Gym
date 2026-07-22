import 'dart:convert';

import 'package:rg_gym/models/routine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineStorage {
  static const _key = 'routines';

  static Future<List<Routine>> getAll() async {
    final sp = await SharedPreferences.getInstance();
    final data = sp.getStringList(_key) ?? [];

    return data
        .map((routine) => Routine.fromJson(jsonDecode(routine)))
        .toList();
  }

  static Future<void> saveAll(List<Routine> routines) async {
    final sp = await SharedPreferences.getInstance();
    final data = routines.map((r) => jsonEncode(r.toJson())).toList();

    await sp.setStringList(_key, data);
  }
}