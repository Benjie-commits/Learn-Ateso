import 'package:flutter/material.dart';

import '../hub/downloads_stub_screen.dart';
import '../hub/games_stub_screen.dart';
import '../hub/profile_stub_screen.dart';
import '../hub/settings_stub_screen.dart';
import '../lesson_list/lesson_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    LessonListScreen(),
    DownloadsStubScreen(),
    ProfileStubScreen(),
    GamesStubScreen(),
    SettingsStubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Lessons'),
          NavigationDestination(icon: Icon(Icons.download_outlined), label: 'Downloads'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.videogame_asset_outlined), label: 'Games'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
