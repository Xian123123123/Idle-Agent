import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/theme_model.dart';
import '../../core/models/agent_model.dart';
import '../../core/engine/simulation_engine.dart';
import 'terminal_controller.dart';
import 'terminal_painter.dart';

class TerminalView extends ConsumerStatefulWidget {
  const TerminalView({super.key});

  @override
  ConsumerState<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends ConsumerState<TerminalView>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;
  SimulationEngine? _engine;
  bool _cursorVisible = true;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _cursorVisible = !_cursorVisible);
          _cursorController.reset();
          _cursorController.forward();
        }
      });
    _cursorController.forward();

    // Start engine after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startEngine();
    });
  }

  void _startEngine() {
    _engine?.dispose();
    _engine = SimulationEngine(agent: Agents.gptEngineer);
    ref.read(terminalControllerProvider.notifier).clear();
    ref.read(terminalControllerProvider.notifier).subscribe(_engine!);
    _engine!.start();
  }

  void updateAgent(AgentModel agent, {double speedFactor = 1.0}) {
    _engine?.dispose();
    _engine = SimulationEngine(agent: agent, speedFactor: speedFactor);
    ref.read(terminalControllerProvider.notifier).clear();
    ref.read(terminalControllerProvider.notifier).subscribe(_engine!);
    _engine!.start();
  }

  void pauseEngine() {
    _engine?.stop();
  }

  void resumeEngine() {
    _engine?.start();
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _engine?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terminalState = ref.watch(terminalControllerProvider);
    const theme = Themes.hackerGreen;

    return RepaintBoundary(
      child: Container(
        color: theme.background,
        child: Stack(
          children: [
            // Terminal canvas
            CustomPaint(
              painter: TerminalPainter(
                lines: terminalState.lines,
                theme: theme,
                showCursor: _cursorVisible,
              ),
              size: Size.infinite,
            ),
            // Agent badge top-right
            if (_engine != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.background.withValues(alpha: 0.8),
                    border: Border.all(color: theme.textComment),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _engine!.agent.name,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 10,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
