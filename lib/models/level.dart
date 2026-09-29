import 'puzzle.dart';

/// Shared content only — no `locked` field here. Lock state is per-user and
/// is derived at the view-model layer (see LevelViewModel), not stored on
/// this shared content model, since the same Level is locked for one user
/// and unlocked for another.
class Level {
  const Level({
    required this.id,
    required this.name,
    required this.order,
    required this.puzzle,
  });

  final String id;
  final String name;
  final int order;
  final Puzzle puzzle;

  factory Level.fromMap(String id, Map<String, dynamic> map) {
    return Level(
      id: id,
      name: map['name'] as String? ?? '',
      order: map['order'] as int? ?? 0,
      puzzle: Puzzle.fromMap(
        '$id-puzzle',
        Map<String, dynamic>.from(map['puzzle'] as Map? ?? const {}),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'order': order, 'puzzle': puzzle.toMap()};
  }
}
