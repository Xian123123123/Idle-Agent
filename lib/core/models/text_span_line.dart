import 'package:flutter/painting.dart';

class HighlightToken {
  final String text;
  final Color color;
  final bool bold;

  const HighlightToken({
    required this.text,
    required this.color,
    this.bold = false,
  });
}

class TextSpanLine {
  final List<HighlightToken> tokens;
  final int delayMs;

  const TextSpanLine({
    required this.tokens,
    this.delayMs = 0,
  });
}
