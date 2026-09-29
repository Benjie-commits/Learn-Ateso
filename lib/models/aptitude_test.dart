import 'quiz_question.dart';

/// MVP-only content structure. Not present in the original domain model doc;
/// added because the SRS requires a skip/aptitude test per level.
class AptitudeTest {
  const AptitudeTest({
    required this.levelId,
    required this.questions,
    required this.passThreshold,
  });

  final String levelId;
  final List<QuizQuestion> questions;

  /// Minimum number of correct answers required to pass.
  final int passThreshold;

  factory AptitudeTest.fromMap(String levelId, Map<String, dynamic> map) {
    return AptitudeTest(
      levelId: levelId,
      questions: (map['questions'] as List? ?? const [])
          .map((q) => QuizQuestion.fromMap(Map<String, dynamic>.from(q as Map)))
          .toList(),
      passThreshold: map['passThreshold'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questions': questions.map((q) => q.toMap()).toList(),
      'passThreshold': passThreshold,
    };
  }
}
