import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0E0A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00FF41),
      secondary: Color(0xFF00BCD4),
      surface: Color(0xFF0D1117),
    ),
    fontFamily: 'JetBrains Mono',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D1117),
      foregroundColor: Color(0xFF00FF41),
      elevation: 0,
    ),
  );
}
