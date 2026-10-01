import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/level_list_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/quests_provider.dart';
import 'widgets/level_card.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      context.read<LevelListProvider>().loadForUser(userId);
      context.read<ProgressProvider>().watchUser(userId);
      context.read<QuestsProvider>().watchUser(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelProvider = context.watch<LevelListProvider>();
    final progress = context.watch<ProgressProvider>().progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('${progress.streakDays}'),
                  const SizedBox(width: 12),
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${progress.points}'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: levelProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final vm in levelProvider.levelViewModels)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: LevelCard(viewModel: vm),
                  ),
              ],
            ),
    );
  }
}
