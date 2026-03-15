import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_profile.dart';
import '../paywall/paywall_screen.dart';
import 'settings_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _agentNameController;
  late TextEditingController _projectNameController;
  late TextEditingController _companyController;
  late TextEditingController _moduleController;
  late String _techStack;
  late List<String> _customModules;
  String _slugPreview = '';

  static const _green = Color(0xFF00FF41);
  static const _bg = Color(0xFF0D1117);
  static const _cardBg = Color(0xFF161B22);
  static const _border = Color(0xFF30363D);
  static const _mono = 'JetBrains Mono';

  @override
  void initState() {
    super.initState();
    final profile = ref.read(settingsProvider).profile;
    _agentNameController = TextEditingController(text: profile.agentName);
    _projectNameController = TextEditingController(text: profile.projectName);
    _companyController = TextEditingController(text: profile.company);
    _moduleController = TextEditingController();
    _techStack = profile.techStack;
    _customModules = List<String>.from(profile.customModules);
    _slugPreview = profile.projectSlug;

    _projectNameController.addListener(() {
      setState(() {
        _slugPreview = UserProfile.slugify(_projectNameController.text);
      });
    });
  }

  @override
  void dispose() {
    _agentNameController.dispose();
    _projectNameController.dispose();
    _companyController.dispose();
    _moduleController.dispose();
    super.dispose();
  }

  void _saveAndPop() {
    final notifier = ref.read(settingsProvider.notifier);
    final profile = UserProfile(
      agentName: _agentNameController.text.trim(),
      projectName: _projectNameController.text.trim(),
      projectSlug: _slugPreview,
      company: _companyController.text.trim(),
      techStack: _techStack,
      customModules: _customModules,
      isConfigured: true,
    );
    notifier.setProfile(profile);
    Navigator.of(context).pop();
  }

  void _addModule() {
    final text = _moduleController.text.trim();
    if (text.isEmpty || _customModules.length >= 8 || _customModules.contains(text)) return;
    setState(() {
      _customModules.add(text);
      _moduleController.clear();
    });
  }

  void _removeModule(String module) {
    setState(() {
      _customModules.remove(module);
    });
  }

  InputDecoration _terminalInputDecoration(String placeholder) {
    return InputDecoration(
      hintText: placeholder,
      hintStyle: const TextStyle(
        color: Color(0xFF6E7681),
        fontFamily: _mono,
        fontSize: 13,
      ),
      filled: true,
      fillColor: _cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _border),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _green, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  TextStyle get _inputTextStyle => const TextStyle(
    color: _green,
    fontFamily: _mono,
    fontSize: 13,
  );

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isPro = settings.isPro;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Profile Setup'),
        backgroundColor: _bg,
        foregroundColor: _green,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Agent Name
          _terminalPrompt('AGENT_NAME'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _agentNameController,
                  style: _inputTextStyle,
                  maxLength: 20,
                  decoration: _terminalInputDecoration('Enter your name (e.g. Alex)'),
                  enabled: isPro,
                ),
              ),
              if (!isPro) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.lock, color: Color(0xFFFFD700), size: 18),
                  ),
                ),
              ],
            ],
          ),
          if (!isPro)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'PRO feature',
                style: TextStyle(color: Color(0xFFFFD700), fontFamily: _mono, fontSize: 10),
              ),
            ),

          const SizedBox(height: 20),

          // Project Name
          _terminalPrompt('PROJECT_NAME'),
          const SizedBox(height: 6),
          TextField(
            controller: _projectNameController,
            style: _inputTextStyle,
            decoration: _terminalInputDecoration('e.g. MyStartup Backend'),
          ),
          if (_slugPreview.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'slug: $_slugPreview',
                style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontFamily: _mono,
                  fontSize: 11,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Company
          _terminalPrompt('COMPANY'),
          const SizedBox(height: 6),
          TextField(
            controller: _companyController,
            style: _inputTextStyle,
            decoration: _terminalInputDecoration('e.g. Acme Corp (optional)'),
          ),

          const SizedBox(height: 20),

          // Tech Stack
          _terminalPrompt('TECH_STACK'),
          const SizedBox(height: 8),
          _buildTechStackSelector(),

          const SizedBox(height: 20),

          // Custom Modules
          _terminalPrompt('CUSTOM_MODULES'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _moduleController,
                  style: _inputTextStyle,
                  decoration: _terminalInputDecoration('e.g. auth_handler'),
                  onSubmitted: (_) => _addModule(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _customModules.length < 8 ? _addModule : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _customModules.length < 8 ? _green : _border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.add,
                    color: _customModules.length < 8 ? _bg : const Color(0xFF6E7681),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (_customModules.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _customModules.map((module) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    border: Border.all(color: _green.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        module,
                        style: const TextStyle(
                          color: _green,
                          fontFamily: _mono,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeModule(module),
                        child: const Icon(Icons.close, color: Color(0xFF8B949E), size: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${_customModules.length}/8 modules',
              style: const TextStyle(
                color: Color(0xFF6E7681),
                fontFamily: _mono,
                fontSize: 10,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAndPop,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: _bg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'SAVE CONFIGURATION',
                style: TextStyle(
                  fontFamily: _mono,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _terminalPrompt(String label) {
    return Row(
      children: [
        const Text(
          '\$ ',
          style: TextStyle(
            color: _green,
            fontFamily: _mono,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: _green,
            fontFamily: _mono,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTechStackSelector() {
    const stacks = ['python', 'typescript', 'rust', 'go'];
    const labels = ['Python', 'TypeScript', 'Rust', 'Go'];
    return Row(
      children: List.generate(stacks.length, (i) {
        final isSelected = _techStack == stacks[i];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _techStack = stacks[i];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _green : _cardBg,
                  border: Border.all(
                    color: isSelected ? _green : _border,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: isSelected ? _bg : Colors.white,
                    fontFamily: _mono,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
