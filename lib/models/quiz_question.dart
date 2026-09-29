/// MVP-only content structure. Not present in the original domain model doc;
/// added because the SRS requires multiple-choice quizzes per lesson.
class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctOptionIndex;

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      prompt: map['prompt'] as String? ?? '',
      options: (map['options'] as List?)?.cast<String>() ?? const [],
      correctOptionIndex: map['correctOptionIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}
