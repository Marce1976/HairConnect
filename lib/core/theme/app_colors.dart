import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static Brightness _brightness = Brightness.light;

  /// Actualiza el brightness para que los colores de texto se adapten.
  static void updateBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  static const Color primary = Color(0xFF2a5173);
  static const Color gold = Color(0xFFc8974a);

  /// Retorna blanco en modo oscuro, textDark en modo claro.
  static Color get textDark =>
      _brightness == Brightness.dark ? Colors.white : const Color(0xFF1a1a2e);

  /// Retorna white60 en modo oscuro, textGrey en modo claro.
  static Color get textGrey =>
      _brightness == Brightness.dark
          ? Colors.white60
          : const Color(0xFF6b7280);

  static Color get background =>
      _brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color(0xFFfafaf8);
}
