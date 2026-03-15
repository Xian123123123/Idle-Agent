import '../models/terminal_line.dart';

class ProgressBarBuilder {
  static List<TerminalLine> build({
    required String label,
    int barWidth = 30,
    int durationSteps = 8,
    int msPerStep = 300,
  }) {
    final lines = <TerminalLine>[];
    for (int i = 1; i <= durationSteps; i++) {
      final progress = i / durationSteps;
      final filled = (progress * barWidth).round();
      final empty = barWidth - filled;
      final bar = '[${'█' * filled}${'░' * empty}]';
      final pct = (progress * 100).round();
      lines.add(TerminalLine(
        text: '  $label $bar $pct%',
        type: LineType.system,
        delayMs: i == 1 ? 200 : msPerStep,
      ));
    }
    lines.add(TerminalLine(
      text: '  $label [${'█' * barWidth}] 100% ✓',
      type: LineType.success,
      delayMs: msPerStep,
    ));
    return lines;
  }
}
