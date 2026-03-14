import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_provider.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        foregroundColor: const Color(0xFF00FF41),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
            const Text(
              'Idle Agent Pro',
              style: TextStyle(
                color: Color(0xFF00FF41),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'JetBrains Mono',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '> unlock full potential',
              style: TextStyle(
                color: const Color(0xFF00FF41).withValues(alpha: 0.6),
                fontSize: 14,
                fontFamily: 'JetBrains Mono',
              ),
            ),
            const SizedBox(height: 32),
            // Feature list
            _featureItem(Icons.smart_toy, 'All 4 AI Agents',
                'Researcher, DevOps, Startup CTO'),
            _featureItem(Icons.palette, 'All 5 Terminal Themes',
                'Cyberpunk Neon, Minimal Dark, Research Lab, Retro UNIX'),
            _featureItem(Icons.speed, 'Speed Control',
                '0.5x, 2x, 4x simulation speeds'),
            _featureItem(Icons.tune, 'Advanced Verbosity',
                'Detailed log output modes'),
            const Spacer(),
            // Price
            const Text(
              '\$4.99',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'one-time purchase',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            // Purchase button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _handlePurchase(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF41),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Unlock Pro',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Restore
            TextButton(
              onPressed: () => _handleRestore(context, ref),
              child: const Text(
                'Restore Purchase',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00FF41), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Replace with real RevenueCat call in Phase 9
  void _handlePurchase(BuildContext context, WidgetRef ref) {
    ref.read(settingsProvider.notifier).setPro(true);
    Navigator.pop(context);
  }

  void _handleRestore(BuildContext context, WidgetRef ref) {
    ref.read(settingsProvider.notifier).setPro(true);
    Navigator.pop(context);
  }
}
