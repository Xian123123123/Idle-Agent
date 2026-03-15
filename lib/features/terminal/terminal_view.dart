import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/theme_model.dart';
import '../../core/models/agent_model.dart';
import '../../core/models/terminal_line.dart';
import '../../core/engine/simulation_engine.dart';
import '../../core/engine/daily_project.dart';
import '../settings/settings_provider.dart';
import '../share/share_service.dart';
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
    with TickerProviderStateMixin {
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

  // "Today's Mission" toast — shown once per app session
  static bool _missionToastShown = false;
  AnimationController? _toastController;
  double _toastOpacity = 0.0;
  Timer? _toastTimer;

  // Share mode state
  bool _shareMode = false;
  final GlobalKey _repaintKey = GlobalKey();
  Timer? _shareAutoTimeout;
  bool _shareOverlayVisible = true;

  // Share hint state
  Timer? _shareHintTimer;

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
        _showMissionToast();
        _scheduleShareHint();
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

  void _showMissionToast() {
    if (_missionToastShown || _usesExternalEngine) return;
    _missionToastShown = true;

    // Fade in after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _toastOpacity = 1.0);

      // Hold for ~4 seconds, then fade out
      _toastTimer = Timer(const Duration(milliseconds: 4000), () {
        if (!mounted) return;
        setState(() => _toastOpacity = 0.0);
      });
    });
  }

  Widget _buildMissionToast(TerminalTheme theme) {
    final project = DailyProjectEngine.today();
    return Positioned(
      top: 48,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _toastOpacity,
          duration: Duration(milliseconds: _toastOpacity == 1.0 ? 300 : 500),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.background.withValues(alpha: 0.95),
              border: Border.all(color: theme.textPrimary.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "TODAY'S MISSION",
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrains Mono',
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '> ${project.slug}',
                  style: TextStyle(
                    color: theme.textSystem,
                    fontSize: 11,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '# ${project.description}',
                  style: TextStyle(
                    color: theme.textComment,
                    fontSize: 10,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Agent deployed. Beginning work...',
                  style: TextStyle(
                    color: theme.textSuccess,
                    fontSize: 10,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Share mode methods ---

  void _enterShareMode() {
    if (_shareMode) return;
    setState(() {
      _shareMode = true;
      _shareOverlayVisible = true;
    });
    _engine?.stop();
    _shareAutoTimeout?.cancel();
    _shareAutoTimeout = Timer(const Duration(seconds: 10), () {
      if (mounted && _shareMode) _exitShareMode();
    });
  }

  void _exitShareMode() {
    _shareAutoTimeout?.cancel();
    setState(() {
      _shareMode = false;
      _shareOverlayVisible = true;
    });
    if (!_batteryPaused) {
      _engine?.start();
    }
  }

  void _toggleShareMode() {
    if (_shareMode) {
      _exitShareMode();
    } else {
      _enterShareMode();
    }
  }

  Future<void> _handleShare(TerminalTheme theme) async {
    final project = DailyProjectEngine.today();
    final agentName = _engine?.agent.name ?? 'Agent';

    // Momentarily hide overlay for clean capture
    setState(() => _shareOverlayVisible = false);

    // Wait for the frame to render without overlay
    await Future.delayed(const Duration(milliseconds: 100));

    await ShareService.captureAndShare(
      repaintKey: _repaintKey,
      projectName: project.name,
      agentName: agentName,
    );

    if (mounted) {
      setState(() => _shareOverlayVisible = true);
    }
  }

  void _scheduleShareHint() async {
    if (_usesExternalEngine) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('share_hint_shown') == true) return;

    _shareHintTimer = Timer(const Duration(seconds: 30), () {
      if (!mounted || _shareMode) return;
      _showShareHintSheet();
    });
  }

  void _showShareHintSheet() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('share_hint_shown') == true) return;

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tip: Tap the screen to share what your agent is building',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text(
                'Got it',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
    await prefs.setBool('share_hint_shown', true);
  }

  Widget _buildWatermarkBadge(TerminalTheme theme) {
    return Positioned(
      bottom: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.background.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\u25C8 IDLE AGENT',
              style: TextStyle(
                color: theme.textPrimary.withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'JetBrains Mono',
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'idleagent.app',
              style: TextStyle(
                color: theme.textComment.withValues(alpha: 0.8),
                fontSize: 9,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOverlay(TerminalTheme theme) {
    if (!_shareOverlayVisible) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 56,
        color: Colors.black.withValues(alpha: 0.7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPillButton(
              label: 'SHARE',
              onTap: () => _handleShare(theme),
              color: theme.textPrimary,
              bgColor: theme.textPrimary.withValues(alpha: 0.15),
            ),
            const SizedBox(width: 16),
            _buildPillButton(
              label: 'RESUME',
              onTap: _exitShareMode,
              color: theme.textComment,
              bgColor: theme.textComment.withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color bgColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'JetBrains Mono',
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  // --- End share mode methods ---

  void _startEngine() {
    final settings = ref.read(settingsProvider);
    final agent = Agents.all.firstWhere(
      (a) => a.id == settings.agentId,
      orElse: () => Agents.gptEngineer,
    );
    _engine?.dispose();
    final profile = settings.profile;
    _engine = SimulationEngine(
      agent: agent,
      speedFactor: settings.speedFactor,
      profile: profile.isConfigured ? profile : null,
    );
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
    _toastTimer?.cancel();
    _toastController?.dispose();
    _shareAutoTimeout?.cancel();
    _shareHintTimer?.cancel();
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

    return GestureDetector(
      onTap: _toggleShareMode,
      child: Stack(
        children: [
          // RepaintBoundary with key for screenshot capture
          RepaintBoundary(
            key: _repaintKey,
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
                  if (!_usesExternalEngine)
                    _buildMissionToast(theme),
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
                  // Watermark badge in share mode (inside RepaintBoundary)
                  if (_shareMode)
                    _buildWatermarkBadge(theme),
                ],
              ),
            ),
          ),
          // Share overlay bar (outside RepaintBoundary)
          if (_shareMode)
            _buildShareOverlay(theme),
        ],
      ),
    );
  }
}
