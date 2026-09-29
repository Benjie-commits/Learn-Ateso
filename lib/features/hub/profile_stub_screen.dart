import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/coming_soon_placeholder.dart';
import '../../providers/auth_provider.dart';
import 'widgets/guest_upgrade_prompt.dart';

class ProfileStubScreen extends StatelessWidget {
  const ProfileStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AuthProvider>().isGuest;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: isGuest
          ? const GuestUpgradePrompt(featureName: 'Profile & leaderboard')
          : const ComingSoonPlaceholder(label: 'Profile & leaderboard', icon: Icons.person_outline),
    );
  }
}
