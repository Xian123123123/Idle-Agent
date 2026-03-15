import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import '../../core/models/agent_model.dart';
import '../../core/models/theme_model.dart';
import '../paywall/paywall_screen.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF0D1117),
        foregroundColor: const Color(0xFF00FF41),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Desk Mode'),
          const SizedBox(height: 8),
          _buildDeskMode(context, ref, settings),
          const SizedBox(height: 24),
          _sectionHeader('Android Screensaver'),
          const SizedBox(height: 8),
          _buildScreensaverButton(context),
          const SizedBox(height: 24),
          _sectionHeader('Display'),
          const SizedBox(height: 8),
          _buildSplitPaneToggle(context, ref, settings),
          const SizedBox(height: 24),
          _sectionHeader('Agent Selection'),
          const SizedBox(height: 8),
          _buildAgentGrid(context, ref, settings),
          const SizedBox(height: 24),
          _sectionHeader('Theme'),
          const SizedBox(height: 8),
          _buildThemeList(context, ref, settings),
          const SizedBox(height: 24),
          _sectionHeader('Speed'),
          const SizedBox(height: 8),
          _buildSpeedControl(ref, settings),
          const SizedBox(height: 24),
          _sectionHeader('Language'),
          const SizedBox(height: 8),
          _buildLanguageControl(ref, settings),
          const SizedBox(height: 24),
          _sectionHeader('Battery Pause'),
          const SizedBox(height: 8),
          _buildBatterySlider(ref, settings),
          const SizedBox(height: 24),
          _sectionHeader('About'),
          const SizedBox(height: 8),
          _buildAbout(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF00FF41),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrains Mono',
      ),
    );
  }

  Widget _buildAgentGrid(BuildContext context, WidgetRef ref, SettingsState settings) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.4,
      children: Agents.all.map((agent) {
        final isSelected = settings.agentId == agent.id;
        return GestureDetector(
          onTap: () {
            if (agent.isPro && !settings.isPro) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PaywallScreen()));
            } else {
              ref.read(settingsProvider.notifier).setAgent(agent.id);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(
                color: isSelected ? const Color(0xFF00FF41) : const Color(0xFF30363D),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        agent.name,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF00FF41) : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (agent.isPro)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  agent.role,
                  style: const TextStyle(color: Color(0xFF8B949E), fontSize: 10),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Text(
                    agent.description,
                    style: const TextStyle(color: Color(0xFF6E7681), fontSize: 9),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThemeList(BuildContext context, WidgetRef ref, SettingsState settings) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: Themes.all.map((theme) {
          final isSelected = settings.themeId == theme.id;
          return GestureDetector(
            onTap: () {
              if (theme.isPro && !settings.isPro) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()));
              } else {
                ref.read(settingsProvider.notifier).setTheme(theme.id);
              }
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.background,
                border: Border.all(
                  color: isSelected ? theme.textPrimary : const Color(0xFF30363D),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          theme.name,
                          style: TextStyle(color: theme.textPrimary, fontSize: 8),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (theme.isPro)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(color: Colors.black, fontSize: 6, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('> init...', style: TextStyle(color: theme.textSystem, fontSize: 7)),
                  Text('import os', style: TextStyle(color: theme.textCode, fontSize: 7)),
                  Text('# ok', style: TextStyle(color: theme.textSuccess, fontSize: 7)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpeedControl(WidgetRef ref, SettingsState settings) {
    const speeds = [0.5, 1.0, 2.0, 4.0];
    return Row(
      children: speeds.map((speed) {
        final isSelected = settings.speedFactor == speed;
        final isPro = speed != 1.0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                if (isPro && !settings.isPro) return;
                ref.read(settingsProvider.notifier).setSpeed(speed);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color(0xFF00FF41) : const Color(0xFF161B22),
                foregroundColor: isSelected ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text('${speed}x', style: const TextStyle(fontSize: 12)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageControl(WidgetRef ref, SettingsState settings) {
    const languages = ['python', 'rust', 'typescript', 'go'];
    return Row(
      children: languages.map((lang) {
        final isSelected = settings.language == lang;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () => ref.read(settingsProvider.notifier).setLanguage(lang),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color(0xFF00FF41) : const Color(0xFF161B22),
                foregroundColor: isSelected ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                lang[0].toUpperCase() + lang.substring(1),
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBatterySlider(WidgetRef ref, SettingsState settings) {
    return Column(
      children: [
        Text(
          'Pause below ${settings.batteryPauseLevel}%',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Slider(
          value: settings.batteryPauseLevel.toDouble(),
          min: 5,
          max: 50,
          divisions: 9,
          activeColor: const Color(0xFF00FF41),
          inactiveColor: const Color(0xFF30363D),
          label: '${settings.batteryPauseLevel}%',
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setBatteryPauseLevel(value.round());
          },
        ),
      ],
    );
  }

  Widget _buildDeskMode(BuildContext context, WidgetRef ref, SettingsState settings) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Keep screen on',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Keep screen on while app is open',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: settings.deskMode,
                activeColor: const Color(0xFF00FF41),
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setDeskMode(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSplitPaneToggle(BuildContext context, WidgetRef ref, SettingsState settings) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Split Pane (Landscape)',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    if (!settings.isPro) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Show two agents side by side when phone is horizontal',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: settings.splitPaneEnabled,
            activeColor: const Color(0xFF00FF41),
            onChanged: settings.isPro
                ? (value) {
                    ref.read(settingsProvider.notifier).setSplitPaneEnabled(value);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildScreensaverButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openDreamSettings(context),
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('Set as Android Screensaver (optional)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00BCD4),
                side: const BorderSide(color: Color(0xFF30363D)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Works on Pixel and stock Android. Not available on Samsung, Xiaomi, or most other brands.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _openDreamSettings(BuildContext context) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screensaver settings are only available on Android.')),
      );
      return;
    }
    try {
      const intent = AndroidIntent(
        action: 'android.settings.DREAM_SETTINGS',
      );
      await intent.launch();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Screensaver settings not available on this device. Use Desk Mode instead \u2014 it works on all phones.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildAbout() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Idle Agent v1.0.0', style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 4),
          Text('Privacy Policy', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 12)),
        ],
      ),
    );
  }
}
