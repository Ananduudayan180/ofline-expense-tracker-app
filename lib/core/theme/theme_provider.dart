import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../database/hive_service.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _themeModeKey = 'app_theme_mode';

  @override
  ThemeMode build() {
    try {
      if (Hive.isBoxOpen(HiveService.settingsBoxName)) {
        final box = HiveService.settingsBox;
        final saved = box.get(_themeModeKey);
        if (saved == 'dark') return ThemeMode.dark;
        if (saved == 'light') return ThemeMode.light;
      }
    } catch (_) {}
    return ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    try {
      if (Hive.isBoxOpen(HiveService.settingsBoxName)) {
        final box = HiveService.settingsBox;
        await box.put(_themeModeKey, next == ThemeMode.dark ? 'dark' : 'light');
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      if (Hive.isBoxOpen(HiveService.settingsBoxName)) {
        final box = HiveService.settingsBox;
        await box.put(
          _themeModeKey,
          mode == ThemeMode.dark ? 'dark' : 'light',
        );
      }
    } catch (_) {}
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
