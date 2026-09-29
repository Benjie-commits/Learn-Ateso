class LessonFlowArgs {
  const LessonFlowArgs({
    required this.lessonId,
    required this.levelId,
    required this.lessonTitle,
  });

  final String lessonId;
  final String levelId;
  final String lessonTitle;
}

class SkipTestArgs {
  const SkipTestArgs({required this.levelId, required this.levelName});

  final String levelId;
  final String levelName;
}

class SkipTestResultArgs {
  const SkipTestResultArgs({
    required this.levelId,
    required this.levelName,
    required this.passed,
    required this.correctCount,
    required this.totalCount,
  });

  final String levelId;
  final String levelName;
  final bool passed;
  final int correctCount;
  final int totalCount;
}
