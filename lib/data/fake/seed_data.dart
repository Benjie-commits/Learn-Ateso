import '../../models/aptitude_test.dart';
import '../../models/dialogue_module.dart';
import '../../models/lesson.dart';
import '../../models/lesson_content.dart';
import '../../models/level.dart';
import '../../models/puzzle.dart';
import '../../models/quiz_question.dart';
import '../../models/sentence_exercise.dart';
import '../../models/vocabulary_item.dart';

/// PLACEHOLDER CONTENT — NOT VERIFIED ATESO.
///
/// Every word/phrase/dialogue line below is a stand-in used only to exercise
/// the UI and data model while real Ateso content (vocabulary, audio,
/// dialogue scripts, grammar notes) is sourced from fluent speakers per
/// SRS section 6.1. Swapping in real content means editing this file's
/// data values only — no model or screen code needs to change.
class SeedData {
  SeedData._();

  static final List<Level> levels = [
    const Level(
      id: 'level_1',
      name: 'Level 1: Greetings',
      order: 1,
      puzzle: Puzzle(id: 'level_1-puzzle', totalPieces: 2),
    ),
    const Level(
      id: 'level_2',
      name: 'Level 2: Everyday Phrases',
      order: 2,
      puzzle: Puzzle(id: 'level_2-puzzle', totalPieces: 2),
    ),
    const Level(
      id: 'level_3',
      name: 'Level 3: Clinical Conversations',
      order: 3,
      puzzle: Puzzle(id: 'level_3-puzzle', totalPieces: 1),
    ),
  ];

  static final Map<String, List<Lesson>> lessonsByLevel = {
    'level_1': const [
      Lesson(id: 'lesson_1_1', levelId: 'level_1', title: 'Saying Hello', order: 1),
      Lesson(id: 'lesson_1_2', levelId: 'level_1', title: 'Introducing Yourself', order: 2),
    ],
    'level_2': const [
      Lesson(id: 'lesson_2_1', levelId: 'level_2', title: 'At the Market', order: 1),
      Lesson(id: 'lesson_2_2', levelId: 'level_2', title: 'Asking for Directions', order: 2),
    ],
    'level_3': const [
      Lesson(id: 'lesson_3_1', levelId: 'level_3', title: 'Greeting a Patient', order: 1),
    ],
  };

  static final Map<String, LessonContent> lessonContent = {
    'lesson_1_1': LessonContent(
      lessonId: 'lesson_1_1',
      vocabulary: const [
        VocabularyItem(word: '[Word 1]', translation: 'Hello (placeholder)', audioRef: null, category: 'greetings'),
        VocabularyItem(word: '[Word 2]', translation: 'Good morning (placeholder)', audioRef: null, category: 'greetings'),
        VocabularyItem(word: '[Word 3]', translation: 'How are you? (placeholder)', audioRef: null, category: 'greetings'),
      ],
      grammarNote: 'PLACEHOLDER grammar note: greetings typically come before '
          'the subject in a sentence. Word order and question formation '
          'details will be added once real grammar content is sourced.',
      quiz: const [
        QuizQuestion(
          prompt: 'Which word means "Hello"?',
          options: ['[Word 1]', '[Word 2]', '[Word 3]'],
          correctOptionIndex: 0,
        ),
        QuizQuestion(
          prompt: 'Which word means "Good morning"?',
          options: ['[Word 3]', '[Word 1]', '[Word 2]'],
          correctOptionIndex: 2,
        ),
        QuizQuestion(
          prompt: 'Which word means "How are you?"',
          options: ['[Word 3]', '[Word 2]', '[Word 1]'],
          correctOptionIndex: 0,
        ),
      ],
      sentenceExercise: const SentenceExercise(
        promptTranslation: 'Arrange the words to say: "Hello, how are you?"',
        scrambledWords: ['[Word 3]', '[Word 1]'],
        correctOrder: ['[Word 1]', '[Word 3]'],
      ),
      dialogue: const DialogueModule(
        id: 'lesson_1_1-dialogue',
        scenario: 'Greeting a neighbor',
        turns: [
          DialogueTurn(speaker: 'npc', line: '[Word 1]! [Word 3]'),
          DialogueTurn(
            speaker: 'user',
            line: '',
            responseOptions: ['[Word 1]! [Word 2].', '[Word 2] only.'],
            correctResponseIndex: 0,
          ),
        ],
      ),
    ),
    'lesson_1_2': LessonContent(
      lessonId: 'lesson_1_2',
      vocabulary: const [
        VocabularyItem(word: '[Word 4]', translation: 'My name is... (placeholder)', audioRef: null, category: 'greetings'),
        VocabularyItem(word: '[Word 5]', translation: 'Nice to meet you (placeholder)', audioRef: null, category: 'greetings'),
      ],
      grammarNote: 'PLACEHOLDER grammar note: introducing yourself uses a '
          'simple subject + phrase pattern.',
      quiz: const [
        QuizQuestion(
          prompt: 'Which phrase means "My name is..."?',
          options: ['[Word 4]', '[Word 5]'],
          correctOptionIndex: 0,
        ),
        QuizQuestion(
          prompt: 'Which phrase means "Nice to meet you"?',
          options: ['[Word 4]', '[Word 5]'],
          correctOptionIndex: 1,
        ),
      ],
      sentenceExercise: const SentenceExercise(
        promptTranslation: 'Arrange the words to introduce yourself.',
        scrambledWords: ['[Word 5]', '[Word 4]'],
        correctOrder: ['[Word 4]', '[Word 5]'],
      ),
      dialogue: const DialogueModule(
        id: 'lesson_1_2-dialogue',
        scenario: 'Meeting someone new',
        turns: [
          DialogueTurn(speaker: 'npc', line: '[Word 1]! [Word 4]?'),
          DialogueTurn(
            speaker: 'user',
            line: '',
            responseOptions: ['[Word 4] Ben.', '[Word 5].'],
            correctResponseIndex: 0,
          ),
        ],
      ),
    ),
    'lesson_2_1': LessonContent(
      lessonId: 'lesson_2_1',
      vocabulary: const [
        VocabularyItem(word: '[Word 6]', translation: 'How much? (placeholder)', audioRef: null, category: 'market'),
        VocabularyItem(word: '[Word 7]', translation: 'Too expensive (placeholder)', audioRef: null, category: 'market'),
      ],
      grammarNote: 'PLACEHOLDER grammar note: question words usually start '
          'the sentence.',
      quiz: const [
        QuizQuestion(
          prompt: 'Which phrase means "How much?"',
          options: ['[Word 6]', '[Word 7]'],
          correctOptionIndex: 0,
        ),
      ],
      sentenceExercise: const SentenceExercise(
        promptTranslation: 'Arrange the words to ask "How much, it is too expensive?"',
        scrambledWords: ['[Word 7]', '[Word 6]'],
        correctOrder: ['[Word 6]', '[Word 7]'],
      ),
      dialogue: const DialogueModule(
        id: 'lesson_2_1-dialogue',
        scenario: 'Buying vegetables at the market',
        turns: [
          DialogueTurn(speaker: 'npc', line: '[Word 1]!'),
          DialogueTurn(
            speaker: 'user',
            line: '',
            responseOptions: ['[Word 6]?', '[Word 5].'],
            correctResponseIndex: 0,
          ),
        ],
      ),
    ),
    'lesson_2_2': LessonContent(
      lessonId: 'lesson_2_2',
      vocabulary: const [
        VocabularyItem(word: '[Word 8]', translation: 'Where is...? (placeholder)', audioRef: null, category: 'directions'),
        VocabularyItem(word: '[Word 9]', translation: 'Straight ahead (placeholder)', audioRef: null, category: 'directions'),
      ],
      grammarNote: 'PLACEHOLDER grammar note: location phrases follow the '
          'question word.',
      quiz: const [
        QuizQuestion(
          prompt: 'Which phrase means "Where is...?"',
          options: ['[Word 8]', '[Word 9]'],
          correctOptionIndex: 0,
        ),
      ],
      sentenceExercise: const SentenceExercise(
        promptTranslation: 'Arrange the words to ask for directions.',
        scrambledWords: ['[Word 9]', '[Word 8]'],
        correctOrder: ['[Word 8]', '[Word 9]'],
      ),
      dialogue: const DialogueModule(
        id: 'lesson_2_2-dialogue',
        scenario: 'Asking a stranger for directions',
        turns: [
          DialogueTurn(speaker: 'npc', line: '[Word 1]!'),
          DialogueTurn(
            speaker: 'user',
            line: '',
            responseOptions: ['[Word 8] market?', '[Word 7].'],
            correctResponseIndex: 0,
          ),
        ],
      ),
    ),
    'lesson_3_1': LessonContent(
      lessonId: 'lesson_3_1',
      vocabulary: const [
        VocabularyItem(word: '[Word 10]', translation: 'Where does it hurt? (placeholder)', audioRef: null, category: 'clinical'),
        VocabularyItem(word: '[Word 11]', translation: 'Take a deep breath (placeholder)', audioRef: null, category: 'clinical'),
      ],
      grammarNote: 'PLACEHOLDER grammar note: clinical questions follow the '
          'same question-word pattern as everyday questions.',
      quiz: const [
        QuizQuestion(
          prompt: 'Which phrase means "Where does it hurt?"',
          options: ['[Word 10]', '[Word 11]'],
          correctOptionIndex: 0,
        ),
      ],
      sentenceExercise: const SentenceExercise(
        promptTranslation: 'Arrange the words to ask a patient where it hurts.',
        scrambledWords: ['[Word 11]', '[Word 10]'],
        correctOrder: ['[Word 10]'],
      ),
      dialogue: const DialogueModule(
        id: 'lesson_3_1-dialogue',
        scenario: 'Greeting a patient at the clinic',
        turns: [
          DialogueTurn(speaker: 'npc', line: '[Word 1]... [Word 11]?'),
          DialogueTurn(
            speaker: 'user',
            line: '',
            responseOptions: ['[Word 10]?', '[Word 6]?'],
            correctResponseIndex: 0,
          ),
        ],
      ),
    ),
  };

  static final Map<String, AptitudeTest> aptitudeTests = {
    'level_2': const AptitudeTest(
      levelId: 'level_2',
      questions: [
        QuizQuestion(prompt: 'Which word means "Hello"?', options: ['[Word 1]', '[Word 6]'], correctOptionIndex: 0),
        QuizQuestion(prompt: 'Which phrase means "My name is..."?', options: ['[Word 4]', '[Word 8]'], correctOptionIndex: 0),
        QuizQuestion(prompt: 'Which phrase means "Nice to meet you"?', options: ['[Word 5]', '[Word 9]'], correctOptionIndex: 0),
      ],
      passThreshold: 2,
    ),
    'level_3': const AptitudeTest(
      levelId: 'level_3',
      questions: [
        QuizQuestion(prompt: 'Which phrase means "How much?"', options: ['[Word 6]', '[Word 10]'], correctOptionIndex: 0),
        QuizQuestion(prompt: 'Which phrase means "Where is...?"', options: ['[Word 8]', '[Word 11]'], correctOptionIndex: 0),
        QuizQuestion(prompt: 'Which phrase means "Too expensive"?', options: ['[Word 7]', '[Word 9]'], correctOptionIndex: 0),
      ],
      passThreshold: 2,
    ),
  };
}
