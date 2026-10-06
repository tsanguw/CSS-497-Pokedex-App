import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the Pokemon screen shows the grid (true) or the list
/// (false, the default). Failures fall back to the list.
class ViewModePreference {
  static const _key = 'pokemon_grid_view';

  static Future<bool> loadGrid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveGrid(bool grid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, grid);
    } catch (_) {
      // The choice just won't be remembered.
    }
  }
}
