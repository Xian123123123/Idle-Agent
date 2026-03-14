import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_provider.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Placeholder — full implementation in Phase 7
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        foregroundColor: const Color(0xFF00FF41),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Paywall — coming in Phase 7',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
