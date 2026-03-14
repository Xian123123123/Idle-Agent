import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/terminal_line.dart';
import '../../core/engine/simulation_engine.dart';

class TerminalState {
  final List<TerminalLine> lines;
  final int lineCount;

  const TerminalState({this.lines = const [], this.lineCount = 0});

  TerminalState copyWith({List<TerminalLine>? lines, int? lineCount}) {
    return TerminalState(
      lines: lines ?? this.lines,
      lineCount: lineCount ?? this.lineCount,
    );
  }
}

class TerminalController extends StateNotifier<TerminalState> {
  static const _maxLines = 200;
  StreamSubscription<TerminalLine>? _subscription;

  TerminalController() : super(const TerminalState());

  void subscribe(SimulationEngine engine) {
    _subscription?.cancel();
    _subscription = engine.lines.listen(addLine);
  }

  void addLine(TerminalLine line) {
    final newLines = List<TerminalLine>.from(state.lines)..add(line);
    if (newLines.length > _maxLines) {
      newLines.removeRange(0, newLines.length - _maxLines);
    }
    state = state.copyWith(lines: newLines, lineCount: state.lineCount + 1);
  }

  void clear() {
    state = const TerminalState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final terminalControllerProvider =
    StateNotifierProvider<TerminalController, TerminalState>((ref) {
  return TerminalController();
});
