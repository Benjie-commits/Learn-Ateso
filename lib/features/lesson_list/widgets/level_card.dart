import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/routes.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../models/lesson.dart';
import '../../../providers/level_list_provider.dart';
import '../../../routing/route_args.dart';
import 'lesson_tile.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.viewModel});

  final LevelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final level = viewModel.level;
    final pieces = '${viewModel.revealedPuzzlePieces}/${level.puzzle.totalPieces} pieces';

    if (viewModel.locked) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.lock),
          title: Text(level.name),
          subtitle: const Text('Locked — take the skip test to unlock'),
          trailing: TextButton(
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.skipTest,
              arguments: SkipTestArgs(levelId: level.id, levelName: level.name),
            ),
            child: const Text('Skip test'),
          ),
        ),
      );
    }

    return Card(
      child: ExpansionTile(
        leading: Icon(
          viewModel.isComplete ? Icons.emoji_events : Icons.menu_book_outlined,
          color: viewModel.isComplete ? Colors.amber[700] : null,
        ),
        title: Text(level.name),
        subtitle: Text('Puzzle: $pieces'),
        children: [
          FutureBuilder<List<Lesson>>(
            future: context.read<ContentRepository>().getLessonsForLevel(level.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final lessons = snapshot.data!;
              return Column(
                children: [
                  for (var i = 0; i < lessons.length; i++)
                    LessonTile(
                      lesson: lessons[i],
                      completed: viewModel.completedLessonIds.contains(lessons[i].id),
                      locked: i > 0 &&
                          !viewModel.completedLessonIds.contains(lessons[i - 1].id),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
