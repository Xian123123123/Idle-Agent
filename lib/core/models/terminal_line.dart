enum LineType { system, code, success, error, comment, agent, blank }

class TerminalLine {
  final String text;
  final LineType type;
  final int delayMs;

  const TerminalLine({
    required this.text,
    required this.type,
    this.delayMs = 0,
  });
}
