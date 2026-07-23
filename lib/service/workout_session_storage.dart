import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WorkoutSessionStorage {
  static const _key = 'active_workout_session';

  static Future<Map<String, dynamic>?> get() async {
    final sp = await SharedPreferences.getInstance();
    final data = sp.getString(_key);

    if (data == null) return null;

    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<void> save(Map<String, dynamic> json) async {
    final sp = await SharedPreferences.getInstance();

    await sp.setString(_key, jsonEncode(json));
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();

    await sp.remove(_key);
  }
}