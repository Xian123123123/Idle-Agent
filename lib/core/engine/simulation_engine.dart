import 'dart:async';
import '../models/terminal_line.dart';
import '../models/agent_model.dart';
import 'scenario_bank.dart';
import 'token_bank.dart';

class SimulationEngine {
  final AgentModel agent;
  final double speedFactor;

  SimulationEngine({required this.agent, this.speedFactor = 1.0});

  final _controller = StreamController<TerminalLine>.broadcast();
  Stream<TerminalLine> get lines => _controller.stream;

  bool _running = false;

  void start() {
    _running = true;
    _runNextScenario();
  }

  void stop() {
    _running = false;
  }

  void dispose() {
    _running = false;
    _controller.close();
  }

  Future<void> _runNextScenario() async {
    if (!_running) return;

    final scenarios = ScenarioBank.scenariosFor(agent);
    final scenario = TokenBank.pick(scenarios);
    final lines = scenario();

    // Add agent header
    _controller.add(const TerminalLine(text: '', type: LineType.blank));
    _controller.add(TerminalLine(
      text: '\u2500' * 50,
      type: LineType.comment,
    ));
    _controller.add(TerminalLine(
      text: '  Agent: ${agent.name}   Role: ${agent.role}',
      type: LineType.agent,
    ));
    _controller.add(TerminalLine(
      text: '\u2500' * 50,
      type: LineType.comment,
    ));
    _controller.add(const TerminalLine(text: '', type: LineType.blank));

    for (final line in lines) {
      if (!_running) return;
      final delay = (line.delayMs / speedFactor).round();
      await Future.delayed(Duration(milliseconds: delay));
      if (!_running) return;
      _controller.add(line);
    }

    // Pause between scenarios
    await Future.delayed(Duration(seconds: (3 / speedFactor).round()));
    if (_running) _runNextScenario();
  }
}
