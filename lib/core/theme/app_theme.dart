import 'package:flutter/material.dart';

/// Color palette mirrors the dark red/charcoal Figma F1 Tracker prototype.
abstract final class F1Colors {
  static const background = Color(0xFF090C12);
  static const surface = Color(0xFF151A23);
  static const elevated = Color(0xFF202735);
  static const border = Color(0xFF303847);
  static const white = Color(0xFFF7F8FA);
  static const muted = Color(0xFF9BA6B6);
  static const red = Color(0xFFE10600);
  static const green = Color(0xFF41D8A6);
  static const amber = Color(0xFFFFCA70);
}

abstract final class F1Theme {
  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? F1Colors.surface : const Color(0xFFFFFFFF);
    final foreground = dark ? F1Colors.white : const Color(0xFF151A23);
    final scheme = ColorScheme.fromSeed(
      seedColor: F1Colors.red,
      brightness: brightness,
      surface: surface,
      primary: F1Colors.red,
      onPrimary: Colors.white,
    );

    final outline = dark ? F1Colors.border : const Color(0xFFD7DCE4);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? F1Colors.background : const Color(0xFFF3F5F8),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? F1Colors.background : const Color(0xFFF3F5F8),
        elevation: 0,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? F1Colors.surface : Colors.white,
        hintStyle: TextStyle(color: dark ? F1Colors.muted : Colors.black45),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: F1Colors.red, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: F1Colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: foreground),
        headlineMedium: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: foreground),
        titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: foreground),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: foreground),
        bodyMedium: TextStyle(fontSize: 14, color: foreground),
        bodySmall: TextStyle(fontSize: 12, color: dark ? F1Colors.muted : Colors.black54),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? F1Colors.surface : Colors.white,
        indicatorColor: F1Colors.red.withValues(alpha: 0.16),
        height: 76,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: foreground),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1),
    );
  }
}
