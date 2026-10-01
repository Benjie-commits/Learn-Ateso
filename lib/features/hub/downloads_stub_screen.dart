import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../downloads/downloads_view.dart';
import 'widgets/guest_upgrade_prompt.dart';

class DownloadsStubScreen extends StatelessWidget {
  const DownloadsStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AuthProvider>().isGuest;
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: isGuest
          ? const GuestUpgradePrompt(featureName: 'Downloads')
          : const DownloadsView(),
    );
  }
}
