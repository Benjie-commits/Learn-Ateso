import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/primary_button.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../models/vocabulary_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/level_list_provider.dart';
import 'word_match_game_logic.dart';

/// Gameplay screen for the Word Match mini-game. Vocabulary is drawn from
/// lessons in levels the player already has unlocked (via
/// [LevelListProvider] + [ContentRepository] — no separate unlock logic is
/// duplicated here), so a brand-new guest only sees words from Level 1.
class WordMatchGameScreen extends StatefulWidget {
  const WordMatchGameScreen({super.key});

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

enum _Status { loading, notEnoughVocabulary, playing, finished }

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  _Status _status = _Status.loading;
  List<VocabularyItem> _pool = [];
  WordMatchGame? _game;
  WordMatchRound? _activeRound;

  String? _selectedOption;
  bool? _wasCorrect;
  bool _isSavingScore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPoolAndStart());
  }

  Future<void> _loadPoolAndStart() async {
    final contentRepository = context.read<ContentRepository>();
    final levelViewModels = context.read<LevelListProvider>().levelViewModels;
    final unlockedLevelIds = levelViewModels.where((vm) => !vm.locked).map((vm) => vm.level.id);

    final pool = <VocabularyItem>[];
    for (final levelId in unlockedLevelIds) {
      final lessons = await contentRepository.getLessonsForLevel(levelId);
      for (final lesson in lessons) {
        final content = await contentRepository.getLessonContent(lesson.id);
        pool.addAll(content.vocabulary);
      }
    }

    if (!mounted) return;
    setState(() {
      _pool = pool;
      _startGame();
    });
  }

  void _startGame() {
    final game = WordMatchGame(pool: _pool);
    _game = game;
    _activeRound = game.currentRound;
    _selectedOption = null;
    _wasCorrect = null;
    _status = game.rounds.isEmpty ? _Status.notEnoughVocabulary : _Status.playing;
  }

  void _selectOption(String option) {
    final game = _game;
    if (game == null || _selectedOption != null) return;

    final isCorrect = game.submitAnswer(option);
    setState(() {
      _selectedOption = option;
      _wasCorrect = isCorrect;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (game.isComplete) {
        _finishGame();
      } else {
        setState(() {
          _activeRound = game.currentRound;
          _selectedOption = null;
          _wasCorrect = null;
        });
      }
    });
  }

  Future<void> _finishGame() async {
    setState(() {
      _status = _Status.finished;
      _isSavingScore = true;
    });

    final game = _game;
    final user = context.read<AuthProvider>().user;
    if (game != null && user != null && game.pointsEarned > 0) {
      await context.read<ProgressRepository>().recordMiniGameScore(
            userId: user.id,
            userName: user.name,
            pointsEarned: game.pointsEarned,
          );
    }

    if (!mounted) return;
    setState(() => _isSavingScore = false);
  }

  void _playAgain() {
    setState(_startGame);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Match')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (_status) {
            _Status.loading => const Center(child: CircularProgressIndicator()),
            _Status.notEnoughVocabulary => const _NotEnoughVocabulary(),
            _Status.playing => _PlayingView(
                game: _game!,
                round: _activeRound!,
                selectedOption: _selectedOption,
                wasCorrect: _wasCorrect,
                onSelect: _selectOption,
              ),
            _Status.finished => _ResultsView(
                game: _game!,
                isSaving: _isSavingScore,
                onPlayAgain: _playAgain,
              ),
          },
        ),
      ),
    );
  }
}

class _NotEnoughVocabulary extends StatelessWidget {
  const _NotEnoughVocabulary();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.extension_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          const Text(
            'Complete a lesson or two first — Word Match needs a few more '
            'words to pick from before it can quiz you.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Back to Games', onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class _PlayingView extends StatelessWidget {
  const _PlayingView({
    required this.game,
    required this.round,
    required this.selectedOption,
    required this.wasCorrect,
    required this.onSelect,
  });

  final WordMatchGame game;
  final WordMatchRound round;
  final String? selectedOption;
  final bool? wasCorrect;
  final void Function(String option) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Round ${game.currentRoundIndex + 1}/${game.rounds.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text('What does this mean?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(round.word, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              for (final option in round.options)
                _OptionTile(
                  label: option,
                  isCorrectAnswer: option == round.correctAnswer,
                  isSelected: option == selectedOption,
                  revealResult: selectedOption != null,
                  onTap: () => onSelect(option),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.isCorrectAnswer,
    required this.isSelected,
    required this.revealResult,
    required this.onTap,
  });

  final String label;
  final bool isCorrectAnswer;
  final bool isSelected;
  final bool revealResult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color? color;
    Widget? trailing;
    if (revealResult && isCorrectAnswer) {
      color = Colors.green.withValues(alpha: 0.2);
      trailing = const Icon(Icons.check_circle, color: Colors.green);
    } else if (revealResult && isSelected) {
      color = Colors.red.withValues(alpha: 0.2);
      trailing = const Icon(Icons.cancel, color: Colors.red);
    }

    return Card(
      color: color,
      child: ListTile(
        title: Text(label),
        trailing: trailing,
        onTap: revealResult ? null : onTap,
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    required this.game,
    required this.isSaving,
    required this.onPlayAgain,
  });

  final WordMatchGame game;
  final bool isSaving;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 72, color: Colors.amber),
          const SizedBox(height: 16),
          Text('Score: ${game.score}/${game.rounds.length}',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('+${game.pointsEarned} points'),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Play again',
            isLoading: isSaving,
            onPressed: onPlayAgain,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Games'),
          ),
        ],
      ),
    );
  }
}
