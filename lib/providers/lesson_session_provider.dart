import 'package:flutter/foundation.dart';

import '../data/repositories/content_repository.dart';
import '../models/lesson_content.dart';

/// Holds an in-progress lesson's content and the learner's answers as they
/// move through the pipeline: detail -> grammar -> quiz -> sentence ->
/// conversation -> complete. Reset between lessons.
class LessonSessionProvider extends ChangeNotifier {
  LessonSessionProvider(this._contentRepository);

  final ContentRepository _contentRepository;

  String? _lessonId;
  String? _levelId;
  LessonContent? _content;
  bool _isLoading = false;

  final Map<int, int> _quizAnswers = {};
  bool _sentenceCorrect = false;
  bool _dialogueCompleted = false;

  String? get lessonId => _lessonId;
  String? get levelId => _levelId;
  LessonContent? get content => _content;
  bool get isLoading => _isLoading;
  bool get sentenceCorrect => _sentenceCorrect;
  bool get dialogueCompleted => _dialogueCompleted;

  Future<void> loadLesson({required String lessonId, required String levelId}) async {
    _lessonId = lessonId;
    _levelId = levelId;
    _content = null;
    _quizAnswers.clear();
    _sentenceCorrect = false;
    _dialogueCompleted = false;
    _isLoading = true;
    notifyListeners();

    _content = await _contentRepository.getLessonContent(lessonId);
    _isLoading = false;
    notifyListeners();
  }

  void answerQuizQuestion(int questionIndex, int selectedOptionIndex) {
    _quizAnswers[questionIndex] = selectedOptionIndex;
    notifyListeners();
  }

  int? answerFor(int questionIndex) => _quizAnswers[questionIndex];

  int get quizScore {
    final quiz = _content?.quiz ?? const [];
    var correct = 0;
    for (var i = 0; i < quiz.length; i++) {
      if (_quizAnswers[i] == quiz[i].correctOptionIndex) {
        correct++;
      }
    }
    return correct;
  }

  void markSentenceCorrect(bool correct) {
    _sentenceCorrect = correct;
    notifyListeners();
  }

  void markDialogueCompleted() {
    _dialogueCompleted = true;
    notifyListeners();
  }

  void reset() {
    _lessonId = null;
    _levelId = null;
    _content = null;
    _quizAnswers.clear();
    _sentenceCorrect = false;
    _dialogueCompleted = false;
    notifyListeners();
  }
}
