import 'dart:async';
import '../models/terminal_line.dart';
import '../models/agent_model.dart';
import '../models/user_profile.dart';
import 'scenario_bank.dart';
import 'token_bank.dart';

class SimulationEngine {
  final AgentModel agent;
  final double speedFactor;
  final UserProfile? profile;

  SimulationEngine({required this.agent, this.speedFactor = 1.0, this.profile});

  final _controller = StreamController<TerminalLine>.broadcast();
  Stream<TerminalLine> get lines => _controller.stream;

  bool _running = false;
  late DateTime _simulatedTime;

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

  String _timestamp() {
    final h = _simulatedTime.hour.toString().padLeft(2, '0');
    final m = _simulatedTime.minute.toString().padLeft(2, '0');
    final s = _simulatedTime.second.toString().padLeft(2, '0');
    return '[$h:$m:$s]';
  }

  void _advanceTime() {
    _simulatedTime = _simulatedTime.add(
      Duration(milliseconds: 50 + TokenBank.rng.nextInt(1951)),
    );
  }

  TerminalLine _withTimestamp(TerminalLine line) {
    if (line.type == LineType.code || line.type == LineType.blank || line.type == LineType.comment) {
      return line;
    }
    _advanceTime();
    return TerminalLine(
      text: '${_timestamp()} ${line.text}',
      type: line.type,
      delayMs: line.delayMs,
    );
  }

  Future<void> _runNextScenario() async {
    if (!_running) return;

    // Initialize simulated time for this scenario
    _simulatedTime = DateTime(
      2026,
      1 + TokenBank.rng.nextInt(12),
      1 + TokenBank.rng.nextInt(28),
      TokenBank.rng.nextInt(24),
      TokenBank.rng.nextInt(60),
      TokenBank.rng.nextInt(60),
    );

    // Set profile on ScenarioBank so scenarios can read it
    ScenarioBank.activeProfile = (profile != null && profile!.isConfigured) ? profile : null;

    final scenarios = ScenarioBank.scenariosFor(agent);
    final scenario = TokenBank.pick(scenarios);
    final lines = scenario();

    // Add agent header
    final agentDisplayName = (profile != null && profile!.isConfigured && profile!.agentName.isNotEmpty)
        ? profile!.agentName
        : agent.name;
    _controller.add(const TerminalLine(text: '', type: LineType.blank));
    _controller.add(TerminalLine(
      text: '\u2500' * 50,
      type: LineType.comment,
    ));
    _controller.add(TerminalLine(
      text: '  Agent: $agentDisplayName   Role: ${agent.role}',
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
      _controller.add(_withTimestamp(line));
    }

    // 10% chance of git log after each scenario
    if (TokenBank.randInt(0, 10) == 0) {
      final gitLines = ScenarioBank.gitLogScene();
      for (final line in gitLines) {
        if (!_running) return;
        final delay = (line.delayMs / speedFactor).round();
        await Future.delayed(Duration(milliseconds: delay));
        if (!_running) return;
        _controller.add(_withTimestamp(line));
      }
    }

    // Pause between scenarios
    await Future.delayed(Duration(seconds: (3 / speedFactor).round()));
    if (_running) _runNextScenario();
  }
}
