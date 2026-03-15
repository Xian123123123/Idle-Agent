import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/user_profile.dart';

class SettingsState {
  final String agentId;
  final String themeId;
  final double speedFactor;
  final String language;
  final bool isPro;
  final int batteryPauseLevel;
  final bool deskMode;
  final bool splitPaneEnabled;
  final bool autoSplitOnLandscape;
  final UserProfile profile;

  const SettingsState({
    this.agentId = 'gpt_engineer',
    this.themeId = 'hacker_green',
    this.speedFactor = 1.0,
    this.language = 'python',
    this.isPro = false,
    this.batteryPauseLevel = 20,
    this.deskMode = true,
    this.splitPaneEnabled = false,
    this.autoSplitOnLandscape = true,
    this.profile = const UserProfile(),
  });

  SettingsState copyWith({
    String? agentId,
    String? themeId,
    double? speedFactor,
    String? language,
    bool? isPro,
    int? batteryPauseLevel,
    bool? deskMode,
    bool? splitPaneEnabled,
    bool? autoSplitOnLandscape,
    UserProfile? profile,
  }) {
    return SettingsState(
      agentId: agentId ?? this.agentId,
      themeId: themeId ?? this.themeId,
      speedFactor: speedFactor ?? this.speedFactor,
      language: language ?? this.language,
      isPro: isPro ?? this.isPro,
      batteryPauseLevel: batteryPauseLevel ?? this.batteryPauseLevel,
      deskMode: deskMode ?? this.deskMode,
      splitPaneEnabled: splitPaneEnabled ?? this.splitPaneEnabled,
      autoSplitOnLandscape: autoSplitOnLandscape ?? this.autoSplitOnLandscape,
      profile: profile ?? this.profile,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    UserProfile profile = const UserProfile();
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      try {
        profile = UserProfile.fromJson(jsonDecode(profileJson));
      } catch (_) {}
    }
    state = SettingsState(
      agentId: prefs.getString('agentId') ?? 'gpt_engineer',
      themeId: prefs.getString('themeId') ?? 'hacker_green',
      speedFactor: prefs.getDouble('speedFactor') ?? 1.0,
      language: prefs.getString('language') ?? 'python',
      isPro: prefs.getBool('isPro') ?? false,
      batteryPauseLevel: prefs.getInt('batteryPauseLevel') ?? 20,
      deskMode: prefs.getBool('deskMode') ?? true,
      splitPaneEnabled: prefs.getBool('splitPaneEnabled') ?? false,
      autoSplitOnLandscape: prefs.getBool('autoSplitOnLandscape') ?? true,
      profile: profile,
    );
  }

  Future<void> _saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(profile.toJson()));
  }

  Future<void> setProfile(UserProfile profile) async {
    state = state.copyWith(profile: profile);
    await _saveProfile(profile);
  }

  Future<void> setAgentName(String name) async {
    final updated = state.profile.copyWith(agentName: name, isConfigured: true);
    state = state.copyWith(profile: updated);
    await _saveProfile(updated);
  }

  Future<void> setProjectName(String name) async {
    final slug = UserProfile.slugify(name);
    final updated = state.profile.copyWith(
      projectName: name,
      projectSlug: slug,
      isConfigured: true,
    );
    state = state.copyWith(profile: updated);
    await _saveProfile(updated);
  }

  Future<void> setCompany(String company) async {
    final updated = state.profile.copyWith(company: company, isConfigured: true);
    state = state.copyWith(profile: updated);
    await _saveProfile(updated);
  }

  Future<void> setProfileTechStack(String stack) async {
    final updated = state.profile.copyWith(techStack: stack, isConfigured: true);
    state = state.copyWith(profile: updated);
    await _saveProfile(updated);
  }

  Future<void> addCustomModule(String module) async {
    if (state.profile.customModules.length >= 8) return;
    final modules = List<String>.from(state.profile.customModules)..add(module);
    final updated = state.profile.copyWith(customModules: modules, isConfigured: true);
    state = state.copyWith(profile: updated);
    await _saveProfile(updated);
  }

  Future<void> removeCustomModule(String module) async {
    final modules = List<String>.from(state.profile.customModules)..remove(module);
    final updated = state.profile.copyWith(customModules: modules);
    state = state.copyWith(profile: updated);
    await _saveProfile(updated);
  }

  Future<void> clearProfile() async {
    const cleared = UserProfile();
    state = state.copyWith(profile: cleared);
    await _saveProfile(cleared);
  }

  Future<void> setAgent(String id) async {
    state = state.copyWith(agentId: id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('agentId', id);
  }

  Future<void> setTheme(String id) async {
    state = state.copyWith(themeId: id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeId', id);
  }

  Future<void> setSpeed(double factor) async {
    state = state.copyWith(speedFactor: factor);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speedFactor', factor);
  }

  Future<void> setLanguage(String lang) async {
    state = state.copyWith(language: lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  Future<void> setPro(bool isPro) async {
    state = state.copyWith(isPro: isPro);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPro', isPro);
  }

  Future<void> setBatteryPauseLevel(int level) async {
    state = state.copyWith(batteryPauseLevel: level);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('batteryPauseLevel', level);
  }

  Future<void> setDeskMode(bool enabled) async {
    state = state.copyWith(deskMode: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('deskMode', enabled);
  }

  Future<void> setSplitPaneEnabled(bool enabled) async {
    state = state.copyWith(splitPaneEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('splitPaneEnabled', enabled);
  }

  Future<void> setAutoSplitOnLandscape(bool enabled) async {
    state = state.copyWith(autoSplitOnLandscape: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSplitOnLandscape', enabled);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
