import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/models/theme_model.dart';
import '../../core/models/agent_model.dart';
import '../../core/models/terminal_line.dart';
import '../../core/engine/simulation_engine.dart';
import '../settings/settings_provider.dart';
import 'terminal_controller.dart';
import 'terminal_painter.dart';

class TerminalView extends ConsumerStatefulWidget {
  final SimulationEngine? engine;
  final TerminalTheme? theme;
  final bool showAgentHeader;

  const TerminalView({
    super.key,
    this.engine,
    this.theme,
    this.showAgentHeader = true,
  });

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

  // Internal state for when an external engine is provided
  bool get _usesExternalEngine => widget.engine != null;
  List<TerminalLine> _localLines = [];
  StreamSubscription<TerminalLine>? _localSubscription;
  static const _maxLines = 200;

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
      if (_usesExternalEngine) {
        _engine = widget.engine;
        _subscribeLocal(_engine!);
      } else {
        _startEngine();
        _startBatteryMonitoring();
        _updateWakelock();
      }
    });
  }

  void _subscribeLocal(SimulationEngine engine) {
    _localSubscription?.cancel();
    _localSubscription = engine.lines.listen((line) {
      setState(() {
        _localLines = List<TerminalLine>.from(_localLines)..add(line);
        if (_localLines.length > _maxLines) {
          _localLines.removeRange(0, _localLines.length - _maxLines);
        }
      });
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
        if (_usesExternalEngine) {
          setState(() {
            _localLines = List<TerminalLine>.from(_localLines)
              ..add(const TerminalLine(text: '', type: LineType.blank))
              ..add(const TerminalLine(
                text: '\u23f8 Paused \u2014 battery low',
                type: LineType.comment,
              ));
          });
        } else {
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
      }
    });
  }

  void _updateWakelock() {
    final settings = ref.read(settingsProvider);
    if (settings.deskMode) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  @override
  void dispose() {
    if (!_usesExternalEngine) {
      WakelockPlus.disable();
      _engine?.dispose();
    }
    _cursorController.dispose();
    _batterySubscription?.cancel();
    _localSubscription?.cancel();
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
    final List<TerminalLine> displayLines;
    final TerminalTheme theme;

    if (_usesExternalEngine) {
      displayLines = _localLines;
      theme = widget.theme ?? _currentTheme(ref.watch(settingsProvider));
    } else {
      final terminalState = ref.watch(terminalControllerProvider);
      displayLines = terminalState.lines;
      final settings = ref.watch(settingsProvider);
      theme = _currentTheme(settings);

      ref.listen(settingsProvider, (prev, next) {
        if (prev?.agentId != next.agentId || prev?.speedFactor != next.speedFactor) {
          _startEngine();
        }
        if (prev?.deskMode != next.deskMode) {
          _updateWakelock();
        }
      });
    }

    final effectiveEngine = _usesExternalEngine ? widget.engine : _engine;

    return RepaintBoundary(
      child: Container(
        color: theme.background,
        child: Stack(
          children: [
            CustomPaint(
              painter: TerminalPainter(
                lines: displayLines,
                theme: theme,
                showCursor: _cursorVisible,
              ),
              size: Size.infinite,
            ),
            if (widget.showAgentHeader && effectiveEngine != null)
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
                    '${effectiveEngine.agent.name}${_batteryPaused ? ' [paused]' : ''}',
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
