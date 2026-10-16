import 'package:flutter/material.dart';

import '../../core/constants/routes.dart';

/// Replaces the former "coming soon" stub. Per the navigation workflow doc,
/// Games has no guest gate — unlike Downloads/Profile/Settings, every user
/// (guest or full account) can play, so this screen does not check
/// AuthProvider at all.
///
/// Lists available mini-games (SRS 3.3: "game-based modes ... to reinforce
/// learning"). Just one for now: Word Match.
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.extension_outlined, size: 36),
              title: const Text('Word Match'),
              subtitle: const Text('Match Ateso words to their translations'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(Routes.wordMatchGame),
            ),
          ),
        ],
      ),
    );
  }
}
