import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_ateso/features/games/word_match_game_logic.dart';
import 'package:learn_ateso/models/vocabulary_item.dart';

VocabularyItem _item(String word, String translation) {
  return VocabularyItem(word: word, translation: translation, category: 'test');
}

void main() {
  group('WordMatchGame.buildRounds', () {
    final pool = [
      _item('Word1', 'one'),
      _item('Word2', 'two'),
      _item('Word3', 'three'),
      _item('Word4', 'four'),
      _item('Word5', 'five'),
    ];

    test('every round contains the correct answer among its options', () {
      final rounds = WordMatchGame.buildRounds(pool: pool, roundCount: 20, random: Random(1));

      for (final round in rounds) {
        expect(round.options, contains(round.correctAnswer));
      }
    });

    test('a round never contains duplicate options', () {
      final rounds = WordMatchGame.buildRounds(pool: pool, roundCount: 20, random: Random(2));

      for (final round in rounds) {
        expect(round.options.toSet().length, round.options.length);
      }
    });

    test('uses up to 4 options when the pool is large enough', () {
      final rounds = WordMatchGame.buildRounds(pool: pool, roundCount: 5, random: Random(3));

      for (final round in rounds) {
        expect(round.options.length, 4);
      }
    });

    test('degrades to fewer options when the pool is small, instead of throwing', () {
      final smallPool = [_item('Word1', 'one'), _item('Word2', 'two'), _item('Word3', 'three')];
      final rounds = WordMatchGame.buildRounds(pool: smallPool, roundCount: 5, random: Random(4));

      expect(rounds, isNotEmpty);
      for (final round in rounds) {
        expect(round.options.length, 3);
        expect(round.options, contains(round.correctAnswer));
      }
    });

    test('returns no rounds when fewer than 2 distinct translations are available', () {
      expect(WordMatchGame.buildRounds(pool: []), isEmpty);
      expect(WordMatchGame.buildRounds(pool: [_item('Word1', 'one')]), isEmpty);
      // Two items sharing a translation still only give 1 distinct option.
      expect(
        WordMatchGame.buildRounds(pool: [_item('Word1', 'one'), _item('Word1b', 'one')]),
        isEmpty,
      );
    });

    test('ignores items with an empty word or translation', () {
      final poolWithBlanks = [
        ...pool,
        _item('', 'blank-translation'),
        _item('blank-word', ''),
      ];
      final rounds = WordMatchGame.buildRounds(pool: poolWithBlanks, roundCount: 10, random: Random(5));

      for (final round in rounds) {
        expect(round.word, isNot(isEmpty));
        expect(round.options, isNot(contains('blank-translation')));
      }
    });

    test('builds the requested number of rounds', () {
      final rounds = WordMatchGame.buildRounds(pool: pool, roundCount: 8, random: Random(6));
      expect(rounds.length, 8);
    });
  });

  group('WordMatchGame session', () {
    final pool = [
      _item('Word1', 'one'),
      _item('Word2', 'two'),
      _item('Word3', 'three'),
      _item('Word4', 'four'),
    ];

    test('submitAnswer scores correctly and advances through rounds', () {
      final game = WordMatchGame(pool: pool, roundCount: 3, random: Random(7));

      expect(game.isComplete, isFalse);
      expect(game.score, 0);

      var round = game.currentRound!;
      final correct = game.submitAnswer(round.correctAnswer);
      expect(correct, isTrue);
      expect(game.score, 1);
      expect(game.currentRoundIndex, 1);

      round = game.currentRound!;
      final wrongOption = round.options.firstWhere((o) => o != round.correctAnswer);
      final wasCorrect = game.submitAnswer(wrongOption);
      expect(wasCorrect, isFalse);
      expect(game.score, 1);

      round = game.currentRound!;
      game.submitAnswer(round.correctAnswer);

      expect(game.isComplete, isTrue);
      expect(game.currentRound, isNull);
      expect(game.score, 2);
      expect(game.pointsEarned, 2 * pointsPerCorrectAnswer);
    });

    test('submitAnswer after completion is a no-op', () {
      final game = WordMatchGame(pool: pool, roundCount: 1, random: Random(8));
      game.submitAnswer(game.currentRound!.correctAnswer);
      expect(game.isComplete, isTrue);

      final result = game.submitAnswer('anything');
      expect(result, isFalse);
      expect(game.score, 1);
    });
  });
}
