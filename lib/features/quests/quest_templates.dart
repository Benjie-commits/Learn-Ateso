import '../../models/weekly_quest.dart';

/// The Monday (local midnight) of the week containing [date]. Quests reset
/// whenever a stored quest's weekStart no longer matches this value.
DateTime weekStartFor(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

/// Bonus points awarded once when a quest's progress first reaches its
/// target (SRS 3.12: "award bonus points and/or an extra puzzle piece" —
/// bonus points only, to keep the reward on the same points ledger as
/// everything else rather than reaching into a specific level's puzzle).
const questCompletionBonus = 20;

class _QuestTemplate {
  const _QuestTemplate(this.type, this.description, this.targetValue);
  final QuestType type;
  final String description;
  final int targetValue;
}

/// A small pool of quest templates that rotates by week number, so the 3
/// active quests change week to week without needing real randomness (kept
/// deterministic so it's testable and reproducible).
const _questPool = [
  _QuestTemplate(QuestType.lessonsCompleted, 'Complete 3 lessons this week', 3),
  _QuestTemplate(QuestType.pointsEarned, 'Earn 30 points this week', 30),
  _QuestTemplate(QuestType.streakMaintained, 'Reach a 3-day streak', 3),
  _QuestTemplate(QuestType.lessonsCompleted, 'Complete 5 lessons this week', 5),
];

List<WeeklyQuest> generateWeeklyQuests(DateTime weekStart) {
  final weekNumber = weekStart.millisecondsSinceEpoch ~/ (7 * 24 * 60 * 60 * 1000);
  final start = weekNumber % _questPool.length;
  final quests = <WeeklyQuest>[];
  for (var i = 0; i < 3; i++) {
    final template = _questPool[(start + i) % _questPool.length];
    quests.add(WeeklyQuest(
      id: 'quest_$i',
      type: template.type,
      description: template.description,
      targetValue: template.targetValue,
      progressValue: 0,
      weekStart: weekStart,
      completed: false,
    ));
  }
  return quests;
}
