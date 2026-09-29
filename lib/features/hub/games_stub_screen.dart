import 'package:flutter/material.dart';

import '../../core/widgets/coming_soon_placeholder.dart';

/// Per the navigation workflow doc, Games has no guest gate — unlike
/// Downloads/Profile/Settings, it's plain "coming soon" for every user.
class GamesStubScreen extends StatelessWidget {
  const GamesStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: const ComingSoonPlaceholder(label: 'Games', icon: Icons.videogame_asset_outlined),
    );
  }
}
