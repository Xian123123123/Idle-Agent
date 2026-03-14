import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/agent_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _page1(),
                  _page2(),
                  _page3(),
                ],
              ),
            ),
            // Page indicator
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? const Color(0xFF00FF41)
                          : const Color(0xFF2D4A2D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page1() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated terminal preview
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00FF41).withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('> initializing agent...', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 12, fontFamily: 'JetBrains Mono')),
                SizedBox(height: 4),
                Text('import torch', style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12, fontFamily: 'JetBrains Mono')),
                SizedBox(height: 4),
                Text('class NeuralNet(nn.Module):', style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12, fontFamily: 'JetBrains Mono')),
                SizedBox(height: 4),
                Text('    def forward(self, x):', style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12, fontFamily: 'JetBrains Mono')),
                SizedBox(height: 4),
                Text('\u2713 all tests passed', style: TextStyle(color: Color(0xFF2ECC71), fontSize: 12, fontFamily: 'JetBrains Mono')),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Your phone just got smarter',
            style: TextStyle(
              color: Color(0xFF00FF41),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Idle Agent turns your idle screen into a live AI coding environment',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _page2() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose your agent',
            style: TextStyle(
              color: Color(0xFF00FF41),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Each agent has their own coding style',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...Agents.all.map((agent) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(agent.name,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      if (agent.isPro) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text('PRO', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${agent.role} — ${agent.description}',
                      style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _page3() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Enable the screensaver',
            style: TextStyle(
              color: Color(0xFF00FF41),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Instructions
          _instructionStep('1', 'Open Settings \u2192 Display \u2192 Screen Saver'),
          _instructionStep('2', 'Select "Idle Agent"'),
          _instructionStep('3', 'Tap "When to start" \u2192 While Charging'),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _finish,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF41),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Let's go",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF41),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(number,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
