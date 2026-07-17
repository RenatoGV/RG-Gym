import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const _key = 'favorites';

  static Future<List<int>> getAll() async {
    final sp = await SharedPreferences.getInstance();

    return (sp.getStringList(_key) ?? [])
        .map(int.parse)
        .toList();
  }

  static Future<bool> contains(int exerciseId) async {
    final sp = await SharedPreferences.getInstance();
    final data = sp.getStringList(_key) ?? [];
    
    return data.contains(exerciseId.toString());
  }

  static Future<void> add(int exerciseId) async {
    final sp = await SharedPreferences.getInstance();
    final data = sp.getStringList(_key) ?? [];

    if (!data.contains(exerciseId.toString())) {
      data.add(exerciseId.toString());
      await sp.setStringList(_key, data);
    }
  }

  static Future<void> remove(int exerciseId) async {
    final sp = await SharedPreferences.getInstance();
    final data = sp.getStringList(_key) ?? [];

    data.remove(exerciseId.toString());
    
    await sp.setStringList(_key, data);
  }
}