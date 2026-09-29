import 'package:flutter/material.dart';

import 'village_view.dart';

/// Pushed-route wrapper around VillageView, used by the "View your village"
/// CTA on the lesson-complete screen. The Profile tab embeds VillageView
/// directly instead (see features/hub/profile_stub_screen.dart).
class VillageScreen extends StatelessWidget {
  const VillageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Village')),
      body: const VillageView(),
    );
  }
}
