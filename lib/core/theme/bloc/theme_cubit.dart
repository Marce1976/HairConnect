import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit para gestionar el modo claro/oscuro.
/// Persiste la preferencia en SharedPreferences.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadPreference();
  }

  static const String _key = 'theme_mode';

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved == 'dark') {
        emit(ThemeMode.dark);
      } else if (saved == 'system') {
        emit(ThemeMode.system);
      } else {
        emit(ThemeMode.light);
      }
    } catch (_) {
      emit(ThemeMode.light);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.system
              ? 'system'
              : 'light';
      await prefs.setString(_key, value);
    } catch (_) {}
  }

  void toggle() {
    final next =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(next);
  }
}
