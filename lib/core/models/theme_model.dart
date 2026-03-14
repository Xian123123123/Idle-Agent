import 'package:flutter/material.dart';

class TerminalTheme {
  final String id;
  final String name;
  final Color background;
  final Color textPrimary;
  final Color textSuccess;
  final Color textError;
  final Color textSystem;
  final Color textCode;
  final Color textComment;
  final Color cursor;
  final bool isPro;

  const TerminalTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.textPrimary,
    required this.textSuccess,
    required this.textError,
    required this.textSystem,
    required this.textCode,
    required this.textComment,
    required this.cursor,
    required this.isPro,
  });
}

class Themes {
  static const hackerGreen = TerminalTheme(
    id: 'hacker_green',
    name: 'Hacker Green',
    background: Color(0xFF0A0E0A),
    textPrimary: Color(0xFF00FF41),
    textSuccess: Color(0xFF2ECC71),
    textError: Color(0xFFFF4757),
    textSystem: Color(0xFF00BCD4),
    textCode: Color(0xFFCCCCCC),
    textComment: Color(0xFF2D4A2D),
    cursor: Color(0xFF00FF41),
    isPro: false,
  );

  static const cyberpunkNeon = TerminalTheme(
    id: 'cyberpunk_neon',
    name: 'Cyberpunk Neon',
    background: Color(0xFF0D0015),
    textPrimary: Color(0xFFFF00FF),
    textSuccess: Color(0xFF00FFFF),
    textError: Color(0xFFFF0040),
    textSystem: Color(0xFFFFFF00),
    textCode: Color(0xFFE0E0E0),
    textComment: Color(0xFF3D0060),
    cursor: Color(0xFFFF00FF),
    isPro: true,
  );

  static const minimalDark = TerminalTheme(
    id: 'minimal_dark',
    name: 'Minimal Dark',
    background: Color(0xFF1A1A1A),
    textPrimary: Color(0xFFE0E0E0),
    textSuccess: Color(0xFF66BB6A),
    textError: Color(0xFFEF5350),
    textSystem: Color(0xFF42A5F5),
    textCode: Color(0xFFB0BEC5),
    textComment: Color(0xFF424242),
    cursor: Color(0xFFE0E0E0),
    isPro: true,
  );

  static const researchLab = TerminalTheme(
    id: 'research_lab',
    name: 'AI Research Lab',
    background: Color(0xFF001020),
    textPrimary: Color(0xFF00D4FF),
    textSuccess: Color(0xFF00FF88),
    textError: Color(0xFFFF6B35),
    textSystem: Color(0xFFFFD700),
    textCode: Color(0xFFCCE5FF),
    textComment: Color(0xFF003040),
    cursor: Color(0xFF00D4FF),
    isPro: true,
  );

  static const retroUnix = TerminalTheme(
    id: 'retro_unix',
    name: 'Retro UNIX',
    background: Color(0xFF1C1007),
    textPrimary: Color(0xFFFFB300),
    textSuccess: Color(0xFFFFCC02),
    textError: Color(0xFFFF6600),
    textSystem: Color(0xFFFFD54F),
    textCode: Color(0xFFFFE082),
    textComment: Color(0xFF3D2800),
    cursor: Color(0xFFFFB300),
    isPro: true,
  );

  static List<TerminalTheme> get all =>
      [hackerGreen, cyberpunkNeon, minimalDark, researchLab, retroUnix];
}
