import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battery_plus/battery_plus.dart';
import '../../core/models/theme_model.dart';
import '../../core/models/agent_model.dart';
import '../../core/models/terminal_line.dart';
import '../../core/engine/simulation_engine.dart';
import '../settings/settings_provider.dart';
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
  bool _batteryPaused = false;
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batterySubscription;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startEngine();
      _startBatteryMonitoring();
    });
  }

  void _startEngine() {
    final settings = ref.read(settingsProvider);
    final agent = Agents.all.firstWhere(
      (a) => a.id == settings.agentId,
      orElse: () => Agents.gptEngineer,
    );
    _engine?.dispose();
    _engine = SimulationEngine(agent: agent, speedFactor: settings.speedFactor);
    ref.read(terminalControllerProvider.notifier).clear();
    ref.read(terminalControllerProvider.notifier).subscribe(_engine!);
    _engine!.start();
  }

  void _startBatteryMonitoring() {
    _batterySubscription = _battery.onBatteryStateChanged.listen((state) async {
      final settings = ref.read(settingsProvider);
      if (state == BatteryState.charging) {
        if (_batteryPaused) {
          setState(() => _batteryPaused = false);
          _engine?.start();
        }
        return;
      }
      final level = await _battery.batteryLevel;
      if (level <= settings.batteryPauseLevel && !_batteryPaused) {
        setState(() => _batteryPaused = true);
        _engine?.stop();
        ref.read(terminalControllerProvider.notifier).addLine(
          const TerminalLine(text: '', type: LineType.blank),
        );
        ref.read(terminalControllerProvider.notifier).addLine(
          const TerminalLine(
            text: '\u23f8 Paused \u2014 battery low',
            type: LineType.comment,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _engine?.dispose();
    _batterySubscription?.cancel();
    super.dispose();
  }

  TerminalTheme _currentTheme(SettingsState settings) {
    return Themes.all.firstWhere(
      (t) => t.id == settings.themeId,
      orElse: () => Themes.hackerGreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final terminalState = ref.watch(terminalControllerProvider);
    final settings = ref.watch(settingsProvider);
    final theme = _currentTheme(settings);

    // Restart engine when agent or speed changes
    ref.listen(settingsProvider, (prev, next) {
      if (prev?.agentId != next.agentId || prev?.speedFactor != next.speedFactor) {
        _startEngine();
      }
    });

    return RepaintBoundary(
      child: Container(
        color: theme.background,
        child: Stack(
          children: [
            CustomPaint(
              painter: TerminalPainter(
                lines: terminalState.lines,
                theme: theme,
                showCursor: _cursorVisible,
              ),
              size: Size.infinite,
            ),
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
                    '${_engine!.agent.name}${_batteryPaused ? ' [paused]' : ''}',
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
