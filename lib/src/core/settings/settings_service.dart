import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String themeModeKey = 'themeMode';

  Future<ThemeMode> themeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(themeModeKey) ?? ThemeMode.system.index;
    return ThemeMode.values[themeModeIndex];
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeModeKey, theme.index);
  }
}
