import 'dialogue_module.dart';
import 'quiz_question.dart';
import 'sentence_exercise.dart';
import 'vocabulary_item.dart';

/// Bundles everything needed to run one lesson's full pipeline in a single
/// fetch (vocabulary -> grammar notes -> quiz -> sentence building ->
/// conversation practice), which is what lets ContentRepository.getLessonContent
/// serve the SRS's <3s lesson-load requirement with one round trip.
class LessonContent {
  const LessonContent({
    required this.lessonId,
    required this.vocabulary,
    required this.grammarNote,
    required this.quiz,
    required this.sentenceExercise,
    required this.dialogue,
  });

  final String lessonId;
  final List<VocabularyItem> vocabulary;

  /// PLACEHOLDER content note: short grammar explanation text. Not verified
  /// Ateso grammar until real content is sourced (SRS 6.1).
  final String grammarNote;
  final List<QuizQuestion> quiz;
  final SentenceExercise sentenceExercise;
  final DialogueModule dialogue;

  factory LessonContent.fromMap(String lessonId, Map<String, dynamic> map) {
    return LessonContent(
      lessonId: lessonId,
      vocabulary: (map['vocabulary'] as List? ?? const [])
          .map((v) => VocabularyItem.fromMap(Map<String, dynamic>.from(v as Map)))
          .toList(),
      grammarNote: map['grammarNote'] as String? ?? '',
      quiz: (map['quiz'] as List? ?? const [])
          .map((q) => QuizQuestion.fromMap(Map<String, dynamic>.from(q as Map)))
          .toList(),
      sentenceExercise: SentenceExercise.fromMap(
        Map<String, dynamic>.from(map['sentenceExercise'] as Map? ?? const {}),
      ),
      dialogue: DialogueModule.fromMap(
        '$lessonId-dialogue',
        Map<String, dynamic>.from(map['dialogue'] as Map? ?? const {}),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vocabulary': vocabulary.map((v) => v.toMap()).toList(),
      'grammarNote': grammarNote,
      'quiz': quiz.map((q) => q.toMap()).toList(),
      'sentenceExercise': sentenceExercise.toMap(),
      'dialogue': dialogue.toMap(),
    };
  }
}
