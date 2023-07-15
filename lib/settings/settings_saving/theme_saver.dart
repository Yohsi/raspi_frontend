import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_mode_handler/theme_mode_manager_interface.dart';

class ThemeSaver implements IThemeModeManager {
  static const String _key = 'theme';

  @override
  Future<String?> loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(_key) as FutureOr<String?>;
  }

  @override
  Future<bool> saveThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_key, value);
  }
}
