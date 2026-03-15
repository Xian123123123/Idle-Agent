import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/engine/simulation_engine.dart';
import '../../core/engine/token_bank.dart';
import '../../core/models/agent_model.dart';
import '../../core/models/theme_model.dart';
import '../settings/settings_provider.dart';
import 'terminal_view.dart';

class SplitPaneView extends ConsumerStatefulWidget {
  const SplitPaneView({super.key});

  @override
  ConsumerState<SplitPaneView> createState() => _SplitPaneViewState();
}

class _SplitPaneViewState extends ConsumerState<SplitPaneView> {
  SimulationEngine? _engineLeft;
  SimulationEngine? _engineRight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initEngines());
  }

  void _initEngines() {
    final settings = ref.read(settingsProvider);
    final primaryAgent = Agents.all.firstWhere(
      (a) => a.id == settings.agentId,
      orElse: () => Agents.gptEngineer,
    );
    _engineLeft = SimulationEngine(
      agent: primaryAgent,
      speedFactor: settings.speedFactor,
    );

    final otherAgents =
        Agents.all.where((a) => a.id != primaryAgent.id).toList();
    final secondaryAgent =
        otherAgents.isNotEmpty ? TokenBank.pick(otherAgents) : Agents.gptEngineer;
    _engineRight = SimulationEngine(
      agent: secondaryAgent,
      speedFactor: settings.speedFactor * 0.85,
    );

    _engineLeft!.start();
    _engineRight!.start();
    setState(() {});
  }

  @override
  void dispose() {
    _engineLeft?.dispose();
    _engineRight?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Themes.all.firstWhere(
      (t) => t.id == settings.themeId,
      orElse: () => Themes.hackerGreen,
    );

    if (_engineLeft == null || _engineRight == null) {
      return Container(color: theme.background);
    }

    return Container(
      color: theme.background,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _PaneHeader(
                  label: '1  ${_engineLeft!.agent.name}',
                  theme: theme,
                  isActive: true,
                ),
                Expanded(
                  child: TerminalView(
                    engine: _engineLeft,
                    theme: theme,
                    showAgentHeader: false,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, color: theme.textComment),
          Expanded(
            child: Column(
              children: [
                _PaneHeader(
                  label: '2  ${_engineRight!.agent.name}',
                  theme: theme,
                  isActive: false,
                ),
                Expanded(
                  child: TerminalView(
                    engine: _engineRight,
                    theme: theme,
                    showAgentHeader: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaneHeader extends StatelessWidget {
  final String label;
  final TerminalTheme theme;
  final bool isActive;

  const _PaneHeader({
    required this.label,
    required this.theme,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: isActive
          ? theme.textPrimary.withValues(alpha: 0.15)
          : theme.background,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 11,
          color: isActive ? theme.textPrimary : theme.textComment,
        ),
      ),
    );
  }
}
