/// MVP-only content structure. Not present in the original domain model doc;
/// added because the SRS requires sentence-construction exercises per lesson.
class SentenceExercise {
  const SentenceExercise({
    required this.promptTranslation,
    required this.scrambledWords,
    required this.correctOrder,
  });

  /// English/interface-language prompt telling the user what to build.
  final String promptTranslation;

  /// The Ateso words, in a shuffled/scrambled order for the exercise UI.
  final List<String> scrambledWords;

  /// The correct sentence, as an ordered list of words matching [scrambledWords].
  final List<String> correctOrder;

  factory SentenceExercise.fromMap(Map<String, dynamic> map) {
    return SentenceExercise(
      promptTranslation: map['promptTranslation'] as String? ?? '',
      scrambledWords: (map['scrambledWords'] as List?)?.cast<String>() ?? const [],
      correctOrder: (map['correctOrder'] as List?)?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'promptTranslation': promptTranslation,
      'scrambledWords': scrambledWords,
      'correctOrder': correctOrder,
    };
  }
}
