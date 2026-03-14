import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/models/terminal_line.dart';
import '../../core/models/theme_model.dart';

class TerminalPainter extends CustomPainter {
  final List<TerminalLine> lines;
  final TerminalTheme theme;
  final double fontSize;
  final double scrollOffset;
  final bool showCursor;

  TerminalPainter({
    required this.lines,
    required this.theme,
    this.fontSize = 13.0,
    this.scrollOffset = 0.0,
    this.showCursor = true,
  });

  double get lineHeight => fontSize * 1.6;

  Color _colorForType(LineType type) {
    switch (type) {
      case LineType.system:
        return theme.textSystem;
      case LineType.code:
        return theme.textCode;
      case LineType.success:
        return theme.textSuccess;
      case LineType.error:
        return theme.textError;
      case LineType.comment:
        return theme.textComment;
      case LineType.agent:
        return theme.textPrimary;
      case LineType.blank:
        return theme.textPrimary;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = theme.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final double paddingLeft = 12.0;
    final double paddingTop = 8.0;
    final double availableHeight = size.height - paddingTop;
    final int visibleLines = (availableHeight / lineHeight).floor();

    // Calculate starting line (render from bottom)
    final int totalLines = lines.length;
    int startLine = totalLines - visibleLines;
    if (startLine < 0) startLine = 0;
    startLine = (startLine - scrollOffset.toInt()).clamp(0, totalLines);

    for (int i = startLine; i < totalLines && i < startLine + visibleLines + 1; i++) {
      final line = lines[i];
      if (line.type == LineType.blank) continue;

      final y = paddingTop + (i - startLine) * lineHeight;
      if (y > size.height) break;

      final paragraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: fontSize,
          maxLines: 1,
          ellipsis: '...',
        ),
      )
        ..pushStyle(ui.TextStyle(color: _colorForType(line.type)))
        ..addText(line.text);

      final paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: size.width - paddingLeft * 2));
      canvas.drawParagraph(paragraph, Offset(paddingLeft, y));
    }

    // Draw blinking cursor at end of last line
    if (showCursor && lines.isNotEmpty) {
      final lastVisibleIndex = (totalLines - 1).clamp(0, totalLines - 1);
      final lastLine = lines[lastVisibleIndex];
      final cursorY = paddingTop + (lastVisibleIndex - startLine) * lineHeight;

      if (cursorY >= 0 && cursorY < size.height) {
        // Estimate text width
        final textWidth = lastLine.text.length * fontSize * 0.6 + paddingLeft;
        final cursorPaint = Paint()..color = theme.cursor;
        canvas.drawRect(
          Rect.fromLTWH(textWidth, cursorY + 2, fontSize * 0.6, fontSize * 1.2),
          cursorPaint,
        );
      }
    }

    // Scanline overlay effect
    final scanlinePaint = Paint()..color = Colors.black.withValues(alpha: 0.03);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), scanlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant TerminalPainter oldDelegate) {
    return oldDelegate.lines.length != lines.length ||
        oldDelegate.showCursor != showCursor ||
        oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.theme.id != theme.id;
  }
}
