import 'dart:math';

import '../../models/vocabulary_item.dart';

/// Points awarded per correct answer in [WordMatchGame]. Deliberately modest
/// (SRS 3.3 treats mini-games as supplementary reinforcement, not a lesson
/// substitute) — a perfect run of [WordMatchGame.defaultRoundCount] rounds
/// earns 16, well under a full lesson's ~10-20+ points.
const pointsPerCorrectAnswer = 2;

/// One round of the word-match game: an Ateso [word] with a set of
/// translation [options] (one of which, equal to [correctAnswer], is
/// right). Pure data, no Flutter dependency, so this and [WordMatchGame]
/// below can be unit-tested without a widget harness.
class WordMatchRound {
  const WordMatchRound({
    required this.word,
    required this.options,
    required this.correctAnswer,
  });

  final String word;
  final List<String> options;
  final String correctAnswer;
}

/// Builds and tracks a Word Match mini-game session: a fixed number of
/// rounds drawn from a pool of [VocabularyItem]s, each with up to
/// [maxOptionsPerRound] options (1 correct + distractors), scored as the
/// player answers.
class WordMatchGame {
  WordMatchGame({
    required List<VocabularyItem> pool,
    int roundCount = defaultRoundCount,
    Random? random,
  }) : rounds = buildRounds(pool: pool, roundCount: roundCount, random: random);

  static const defaultRoundCount = 8;
  static const maxOptionsPerRound = 4;

  final List<WordMatchRound> rounds;

  int _index = 0;
  int _score = 0;

  int get currentRoundIndex => _index;
  int get score => _score;
  int get pointsEarned => _score * pointsPerCorrectAnswer;
  bool get isComplete => _index >= rounds.length;
  WordMatchRound? get currentRound => isComplete ? null : rounds[_index];

  /// Submits [answer] for the current round, returns whether it was
  /// correct, and advances to the next round.
  bool submitAnswer(String answer) {
    final round = currentRound;
    if (round == null) return false;
    final isCorrect = answer == round.correctAnswer;
    if (isCorrect) _score++;
    _index++;
    return isCorrect;
  }

  /// Builds up to [roundCount] rounds from [pool].
  ///
  /// Vocabulary is first deduped by translation — two items sharing a
  /// translation would make a round ambiguous (two "correct" options) — and
  /// then degraded gracefully when the pool is still too small: fewer
  /// options per round (down to 2) rather than throwing, and an empty list
  /// of rounds when there isn't even one distinct pair to quiz on (e.g. a
  /// brand-new guest with only a couple of Level 1 vocab items unlocked).
  static List<WordMatchRound> buildRounds({
    required List<VocabularyItem> pool,
    int roundCount = defaultRoundCount,
    Random? random,
  }) {
    final rng = random ?? Random();

    final seenTranslations = <String>{};
    final distinctItems = <VocabularyItem>[];
    for (final item in pool) {
      if (item.word.isEmpty || item.translation.isEmpty) continue;
      if (seenTranslations.add(item.translation)) {
        distinctItems.add(item);
      }
    }

    if (distinctItems.length < 2) return const [];

    final optionsPerRound = min(maxOptionsPerRound, distinctItems.length);

    final rounds = <WordMatchRound>[];
    for (var i = 0; i < roundCount; i++) {
      final correct = distinctItems[rng.nextInt(distinctItems.length)];
      final distractors = distinctItems.where((v) => v.translation != correct.translation).toList()
        ..shuffle(rng);
      final options = [
        correct.translation,
        ...distractors.take(optionsPerRound - 1).map((v) => v.translation),
      ]..shuffle(rng);
      rounds.add(WordMatchRound(
        word: correct.word,
        options: options,
        correctAnswer: correct.translation,
      ));
    }
    return rounds;
  }
}
