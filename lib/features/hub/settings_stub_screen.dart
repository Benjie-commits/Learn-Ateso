import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/coming_soon_placeholder.dart';
import '../../providers/auth_provider.dart';
import 'widgets/guest_upgrade_prompt.dart';

class SettingsStubScreen extends StatelessWidget {
  const SettingsStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AuthProvider>().isGuest;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: isGuest
          ? const GuestUpgradePrompt(featureName: 'Settings')
          : const ComingSoonPlaceholder(label: 'Settings', icon: Icons.settings_outlined),
    );
  }
}
