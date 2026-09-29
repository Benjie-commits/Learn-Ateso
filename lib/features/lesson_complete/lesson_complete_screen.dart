import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/puzzle_image_reveal.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../models/level_progress.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lesson_session_provider.dart';
import '../../routing/route_args.dart';
import '../village/village_theme.dart';

class LessonCompleteScreen extends StatefulWidget {
  const LessonCompleteScreen({super.key, required this.args});

  final LessonFlowArgs args;

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen> {
  LevelProgress? _levelProgress;
  int _totalPieces = 0;
  int _levelOrder = 1;
  bool _isSaving = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
  }

  Future<void> _complete() async {
    final session = context.read<LessonSessionProvider>();
    final userId = context.read<AuthProvider>().user!.id;
    final contentRepository = context.read<ContentRepository>();
    final progressRepository = context.read<ProgressRepository>();

    final levels = await contentRepository.getLevels();
    final level = levels.firstWhere((l) => l.id == widget.args.levelId);

    final result = await progressRepository.recordLessonCompletion(
      userId: userId,
      lessonId: widget.args.lessonId,
      levelId: widget.args.levelId,
      quizScore: session.quizScore,
    );

    if (!mounted) return;
    setState(() {
      _levelProgress = result;
      _totalPieces = level.puzzle.totalPieces;
      _levelOrder = level.order;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final levelProgress = _levelProgress;
    final isLevelComplete =
        levelProgress != null && levelProgress.revealedPuzzlePositions.length >= _totalPieces;
    final theme = themeForLevelOrder(_levelOrder);

    return Scaffold(
      appBar: AppBar(title: const Text('Lesson complete')),
      body: SafeArea(
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.celebration, size: 72, color: Colors.amber),
                    const SizedBox(height: 16),
                    Text('Great job!', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 24),
                    PuzzleImageReveal(
                      totalPieces: _totalPieces,
                      revealedPositions: levelProgress?.revealedPuzzlePositions ?? const {},
                      icon: theme.puzzleIcon,
                      color: theme.color,
                      size: 160,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${levelProgress?.revealedPuzzlePositions.length ?? 0}/$_totalPieces puzzle pieces',
                    ),
                    if (isLevelComplete) ...[
                      const SizedBox(height: 16),
                      Icon(theme.structureIcon, size: 48, color: theme.color),
                      const SizedBox(height: 8),
                      Text(
                        'Level complete! A ${theme.structureLabel.toLowerCase()} was added to '
                        'your village, and the next level is now unlocked.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pushNamed(Routes.village),
                        child: const Text('View your village'),
                      ),
                    ],
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Back to lessons',
                      onPressed: () {
                        context.read<LessonSessionProvider>().reset();
                        Navigator.of(context).popUntil(ModalRoute.withName(Routes.home));
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
