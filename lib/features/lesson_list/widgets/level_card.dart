import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/routes.dart';
import '../../../core/widgets/puzzle_image_reveal.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../models/lesson.dart';
import '../../../providers/level_list_provider.dart';
import '../../../routing/route_args.dart';
import '../../village/village_theme.dart';
import 'lesson_tile.dart';

/// A level shown as a coloured banner followed by its lessons laid out as a
/// winding path of round nodes.
class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.viewModel});

  final LevelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final level = viewModel.level;
    final theme = themeForLevelOrder(level.order);
    final pieces = '${viewModel.revealedPuzzlePieces}/${level.puzzle.totalPieces} pieces';

    if (viewModel.locked) {
      return Column(
        children: [
          _Banner(
            color: Colors.grey.shade500,
            title: level.name,
            subtitle: 'Locked — take the skip test to unlock',
            trailing: TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () => Navigator.of(context).pushNamed(
                Routes.skipTest,
                arguments: SkipTestArgs(levelId: level.id, levelName: level.name),
              ),
              child: const Text('Skip test'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Column(
      children: [
        _Banner(
          color: theme.color,
          title: level.name,
          subtitle: 'Puzzle: $pieces',
          trailing: PuzzleImageReveal(
            totalPieces: level.puzzle.totalPieces,
            revealedPositions: viewModel.revealedPuzzlePositions,
            icon: theme.puzzleIcon,
            color: theme.color,
            size: 48,
          ),
        ),
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
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  for (var i = 0; i < lessons.length; i++)
                    LessonTile(
                      lesson: lessons[i],
                      index: i,
                      color: theme.color,
                      completed: viewModel.completedLessonIds.contains(lessons[i].id),
                      locked: i > 0 &&
                          !viewModel.completedLessonIds.contains(lessons[i - 1].id),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: HSLColor.fromColor(color)
                .withLightness(
                  (HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0),
                )
                .toColor(),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
