/// What event moves a quest's progress forward. Not part of the literal
/// WEEKLY_QUEST domain model entity (which only has a free-text
/// `description`), but the repositories need to know which event to react
/// to — see quest_templates.dart.
enum QuestType { lessonsCompleted, pointsEarned, streakMaintained }

class WeeklyQuest {
  const WeeklyQuest({
    required this.id,
    required this.type,
    required this.description,
    required this.targetValue,
    required this.progressValue,
    required this.weekStart,
    required this.completed,
  });

  final String id;
  final QuestType type;
  final String description;
  final int targetValue;
  final int progressValue;
  final DateTime weekStart;
  final bool completed;

  WeeklyQuest copyWith({int? progressValue, bool? completed}) {
    return WeeklyQuest(
      id: id,
      type: type,
      description: description,
      targetValue: targetValue,
      progressValue: progressValue ?? this.progressValue,
      weekStart: weekStart,
      completed: completed ?? this.completed,
    );
  }

  factory WeeklyQuest.fromMap(String id, Map<String, dynamic> map) {
    return WeeklyQuest(
      id: id,
      type: QuestType.values.byName(map['type'] as String),
      description: map['description'] as String? ?? '',
      targetValue: map['targetValue'] as int? ?? 1,
      progressValue: map['progressValue'] as int? ?? 0,
      weekStart: DateTime.parse(map['weekStart'] as String),
      completed: map['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'description': description,
      'targetValue': targetValue,
      'progressValue': progressValue,
      'weekStart': weekStart.toIso8601String(),
      'completed': completed,
    };
  }
}
