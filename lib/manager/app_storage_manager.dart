import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorageManager {
  AppStorageManager({
    required this.sharedPreferences,
    required this.flutterSecureStorage,
  }) {
    initStorage();
  }

  SharedPreferences sharedPreferences;
  FlutterSecureStorage flutterSecureStorage;
  final String themeMode = 'themeMode';

  void initStorage() {
    final bool isThemeModeSelected = sharedPreferences.containsKey(themeMode);
    if (!isThemeModeSelected) {
      sharedPreferences.setString(themeMode, AppThemeMode.system.title);
    }
  }

  void clearStorage() {
    flutterSecureStorage.deleteAll();
  }

  void toggleThemeMode(AppThemeMode mode) {
    sharedPreferences.setString(themeMode, mode.title);
  }

  String getThemeMode() {
    return sharedPreferences.getString(themeMode) ?? AppThemeMode.system.title;
  }

  Future<String?> getUserToken() async {
    return flutterSecureStorage.read(key: 'token');
  }

  Future<void> setUserToken(String token) async {
    return flutterSecureStorage.write(key: 'token', value: token);
  }
}

enum AppThemeMode { system, light, dark }

extension AppThemeModeExtension on AppThemeMode {
  String get title {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}
