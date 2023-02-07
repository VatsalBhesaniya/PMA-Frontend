import 'package:flutter/material.dart';
import 'package:pma/manager/app_storage_manager.dart';

class ThemeChanger extends ChangeNotifier {
  ThemeChanger({
    required this.appStorageManager,
  });

  final AppStorageManager appStorageManager;

  ThemeMode getThemeMode() {
    final String mode = appStorageManager.getThemeMode();
    if (mode == AppThemeMode.light.title) {
      return ThemeMode.light;
    }
    if (mode == AppThemeMode.dark.title) {
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  void setTheme(AppThemeMode themeMode) {
    appStorageManager.toggleThemeMode(themeMode);
    notifyListeners();
  }
}
