import 'package:flutter/painting.dart';
import '../models/text_span_line.dart';
import '../models/theme_model.dart';

class SyntaxHighlighter {
  static const _keywords = {
    'def', 'class', 'import', 'from', 'return', 'if', 'else', 'elif',
    'for', 'while', 'try', 'except', 'with', 'as', 'pass', 'raise',
    'yield', 'lambda', 'async', 'await', 'True', 'False', 'None', 'self',
  };

  static const _builtins = {
    'print', 'len', 'range', 'enumerate', 'zip', 'map', 'filter',
    'super', 'isinstance',
  };

  static final _decoratorPattern = RegExp(
    r'@(?:staticmethod|classmethod|property|app\.route|pytest\.mark)\b',
  );

  static final _commentPattern = RegExp(r'(#|//).*$');
  static final _stringPattern = RegExp(r"""('[^']*'|"[^"]*")""");
  static final _numberPattern = RegExp(r'\b\d+\.?\d*\b');
  static final _camelCasePattern = RegExp(r'\b[A-Z][a-zA-Z0-9]+\b');
  static final _operatorPattern = RegExp(r'==|!=|<=|>=|=>|->|[=+\-*/%]');
  static final _wordPattern = RegExp(r'\b\w+\b');

  static const _colorOrange = Color(0xFFE67E22);
  static const _colorPurple = Color(0xFF9B59B6);
  static const _colorGray = Color(0xFF95A5A6);

  /// Highlights a single line of text into a list of [HighlightToken]s.
  static List<HighlightToken> highlight(String line, TerminalTheme theme) {
    if (line.isEmpty) {
      return [HighlightToken(text: '', color: theme.textCode)];
    }

    // Build a color map for each character position.
    final int len = line.length;
    final colors = List<Color>.filled(len, theme.textCode);
    final bolds = List<bool>.filled(len, false);

    // 1. Comments (highest priority — will overwrite everything after).
    final commentMatch = _commentPattern.firstMatch(line);
    if (commentMatch != null) {
      for (int i = commentMatch.start; i < len; i++) {
        colors[i] = theme.textComment;
      }
    }

    // Determine the range to process for non-comment tokens.
    final int limit = commentMatch?.start ?? len;

    // 2. Strings
    for (final m in _stringPattern.allMatches(line)) {
      if (m.start >= limit) break;
      final end = m.end > limit ? limit : m.end;
      for (int i = m.start; i < end; i++) {
        colors[i] = _colorOrange;
      }
    }

    // 3. Decorators (before keywords, since they start with @)
    for (final m in _decoratorPattern.allMatches(line)) {
      if (m.start >= limit) break;
      final end = m.end > limit ? limit : m.end;
      for (int i = m.start; i < end; i++) {
        colors[i] = theme.textSystem;
      }
    }

    // 4. Keywords (only if not already colored by strings)
    for (final m in _wordPattern.allMatches(line)) {
      if (m.start >= limit) break;
      final word = m.group(0)!;
      if (_keywords.contains(word)) {
        // Only apply if not already colored (strings take priority)
        bool alreadyColored = false;
        for (int i = m.start; i < m.end; i++) {
          if (colors[i] == _colorOrange) {
            alreadyColored = true;
            break;
          }
        }
        if (!alreadyColored) {
          for (int i = m.start; i < m.end; i++) {
            colors[i] = theme.textPrimary;
            bolds[i] = true;
          }
        }
      }
    }

    // 5. Built-in functions
    for (final m in _wordPattern.allMatches(line)) {
      if (m.start >= limit) break;
      final word = m.group(0)!;
      if (_builtins.contains(word)) {
        bool alreadyColored = false;
        for (int i = m.start; i < m.end; i++) {
          if (colors[i] != theme.textCode) {
            alreadyColored = true;
            break;
          }
        }
        if (!alreadyColored) {
          for (int i = m.start; i < m.end; i++) {
            colors[i] = theme.textSystem;
          }
        }
      }
    }

    // 6. Numbers
    for (final m in _numberPattern.allMatches(line)) {
      if (m.start >= limit) break;
      bool alreadyColored = false;
      for (int i = m.start; i < m.end; i++) {
        if (colors[i] != theme.textCode) {
          alreadyColored = true;
          break;
        }
      }
      if (!alreadyColored) {
        for (int i = m.start; i < m.end; i++) {
          colors[i] = _colorPurple;
        }
      }
    }

    // 7. Types / CamelCase class names
    for (final m in _camelCasePattern.allMatches(line)) {
      if (m.start >= limit) break;
      bool alreadyColored = false;
      for (int i = m.start; i < m.end; i++) {
        if (colors[i] != theme.textCode) {
          alreadyColored = true;
          break;
        }
      }
      if (!alreadyColored) {
        for (int i = m.start; i < m.end; i++) {
          colors[i] = theme.textSuccess;
        }
      }
    }

    // 8. Operators
    for (final m in _operatorPattern.allMatches(line)) {
      if (m.start >= limit) break;
      bool alreadyColored = false;
      for (int i = m.start; i < m.end; i++) {
        if (colors[i] != theme.textCode) {
          alreadyColored = true;
          break;
        }
      }
      if (!alreadyColored) {
        for (int i = m.start; i < m.end; i++) {
          colors[i] = _colorGray;
        }
      }
    }

    // Merge consecutive characters with the same style into tokens.
    final tokens = <HighlightToken>[];
    int start = 0;
    while (start < len) {
      final Color c = colors[start];
      final bool b = bolds[start];
      int end = start + 1;
      while (end < len && colors[end] == c && bolds[end] == b) {
        end++;
      }
      tokens.add(HighlightToken(
        text: line.substring(start, end),
        color: c,
        bold: b,
      ));
      start = end;
    }

    return tokens;
  }
}
