import 'package:flutter_test/flutter_test.dart';
import 'package:learn_ateso/features/quests/quest_templates.dart';
import 'package:learn_ateso/models/weekly_quest.dart';

void main() {
  group('weekStartFor', () {
    test('returns the Monday of the week for any day in that week', () {
      // 2026-01-05 is a Monday; 2026-01-11 is the following Sunday.
      final monday = DateTime(2026, 1, 5);
      final sunday = DateTime(2026, 1, 11);

      expect(weekStartFor(monday), monday);
      expect(weekStartFor(sunday), monday);
    });
  });

  group('generateWeeklyQuests', () {
    test('always returns exactly 3 fresh, incomplete quests for the given week', () {
      final weekStart = DateTime(2026, 1, 5);
      final quests = generateWeeklyQuests(weekStart);

      expect(quests.length, 3);
      for (final quest in quests) {
        expect(quest.progressValue, 0);
        expect(quest.completed, isFalse);
        expect(quest.weekStart, weekStart);
      }
      expect(quests.map((q) => q.id).toSet().length, 3, reason: 'ids must be unique');
    });

    test('rotates which templates are active across different weeks', () {
      final weekA = DateTime(2026, 1, 5);
      final weekB = weekA.add(const Duration(days: 7));

      final questsA = generateWeeklyQuests(weekA);
      final questsB = generateWeeklyQuests(weekB);

      expect(
        questsA.map((q) => q.description).toList(),
        isNot(equals(questsB.map((q) => q.description).toList())),
      );
    });

    test('a lessonsCompleted quest is present every week (pool guarantees it)', () {
      for (var offset = 0; offset < 4; offset++) {
        final weekStart = DateTime(2026, 1, 5).add(Duration(days: 7 * offset));
        final quests = generateWeeklyQuests(weekStart);
        expect(quests.any((q) => q.type == QuestType.lessonsCompleted), isTrue);
      }
    });
  });
}
