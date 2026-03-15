import 'dart:async';
import '../models/terminal_line.dart';
import '../models/agent_model.dart';
import '../models/user_profile.dart';
import 'daily_project.dart';
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

    // Add structured agent header
    final agentDisplayName = (profile != null && profile!.isConfigured && profile!.agentName.isNotEmpty)
        ? '${profile!.agentName}-Agent'
        : agent.name;
    final projectSlug = (profile != null && profile!.isConfigured && profile!.projectSlug.isNotEmpty)
        ? profile!.projectSlug
        : DailyProjectEngine.today().slug;
    final stack = (profile != null && profile!.isConfigured && profile!.techStack.isNotEmpty)
        ? profile!.techStack
        : 'Python 3.11';
    final taskLabel = TokenBank.pick(const ['auth module', 'data pipeline', 'api layer', 'test suite', 'core engine']);
    final speedLabel = '${speedFactor}x';

    // Pad content to fixed width inside the box
    const boxWidth = 54;
    final nameLine = '\u25C8  $agentDisplayName';
    const statusTag = 'ACTIVE  \u25CF';
    final namePad = boxWidth - 4 - nameLine.length - statusTag.length;
    final nameLinePadded = '  $nameLine${' ' * (namePad > 0 ? namePad : 1)}$statusTag  ';
    final projectLine = '  Project: $projectSlug';
    final projPad = boxWidth - 2 - projectLine.length;
    final projectLinePadded = '$projectLine${' ' * (projPad > 0 ? projPad : 0)}';
    final stackLine = '  Stack: $stack  |  Task: $taskLabel  |  $speedLabel';
    final stackPad = boxWidth - 2 - stackLine.length;
    final stackLinePadded = '$stackLine${' ' * (stackPad > 0 ? stackPad : 0)}';

    _controller.add(const TerminalLine(text: '', type: LineType.blank));
    _controller.add(TerminalLine(
      text: '\u2554${'═' * boxWidth}\u2557',
      type: LineType.agent,
    ));
    _controller.add(TerminalLine(
      text: '\u2551$nameLinePadded\u2551',
      type: LineType.agent,
    ));
    _controller.add(TerminalLine(
      text: '\u2551$projectLinePadded\u2551',
      type: LineType.agent,
    ));
    _controller.add(TerminalLine(
      text: '\u2551$stackLinePadded\u2551',
      type: LineType.agent,
    ));
    _controller.add(TerminalLine(
      text: '\u255A${'═' * boxWidth}\u255D',
      type: LineType.agent,
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
