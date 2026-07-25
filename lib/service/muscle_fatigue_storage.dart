import 'dart:convert';

import 'package:rg_gym/config/data/muscle_groups.dart';
import 'package:rg_gym/models/fatigued_muscle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MuscleFatigueStorage {
  static const _key = 'muscle_fatigue';

  static Future<void> initialize() async {
    final sp = await SharedPreferences.getInstance();

    if(sp.containsKey(_key)) return;

    final now = DateTime.now();
    
    final muscles = muscleGroups
      .map((muscle) => FatiguedMuscle(
            muscleId: muscle.id,
            fatigued: 0.0,
            updatedAt: now
          ))
      .toList();

    await save(muscles);
  }

  static Future<List<FatiguedMuscle>> get() async {
    final sp = await SharedPreferences.getInstance();

    final data = sp.getString(_key);
    if(data == null) return [];

    final json = jsonDecode(data) as List;

    return json
      .map((e) => FatiguedMuscle.fromJson(e))
      .toList();
  }

  static Future<void> save(List<FatiguedMuscle> muscles) async {
    final sp = await SharedPreferences.getInstance();

    final json = muscles
      .map((muscle) => muscle.toJson())
      .toList();

    await sp.setString(_key, jsonEncode(json));
  }
}