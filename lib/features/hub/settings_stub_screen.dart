import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/coming_soon_placeholder.dart';
import '../../data/firebase/firestore_seeder.dart';
import '../../providers/auth_provider.dart';
import 'widgets/guest_upgrade_prompt.dart';

class SettingsStubScreen extends StatefulWidget {
  const SettingsStubScreen({super.key});

  @override
  State<SettingsStubScreen> createState() => _SettingsStubScreenState();
}

class _SettingsStubScreenState extends State<SettingsStubScreen> {
  bool _isSeeding = false;

  Future<void> _seedContent() async {
    setState(() => _isSeeding = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirestoreSeeder().run();
      messenger.showSnackBar(
        const SnackBar(content: Text('Placeholder content seeded to Firestore.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Seeding failed: $e')));
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AuthProvider>().isGuest;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          Expanded(
            child: isGuest
                ? const GuestUpgradePrompt(featureName: 'Settings')
                : const ComingSoonPlaceholder(label: 'Settings', icon: Icons.settings_outlined),
          ),
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: _isSeeding ? null : _seedContent,
                child: Text(_isSeeding ? 'Seeding...' : 'Debug: Seed placeholder content'),
              ),
            ),
        ],
      ),
    );
  }
}
