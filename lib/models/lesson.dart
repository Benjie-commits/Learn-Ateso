/// Shared content only — no `locked` field. See note in level.dart.
class Lesson {
  const Lesson({
    required this.id,
    required this.levelId,
    required this.title,
    required this.order,
  });

  final String id;
  final String levelId;
  final String title;
  final int order;

  factory Lesson.fromMap(String id, String levelId, Map<String, dynamic> map) {
    return Lesson(
      id: id,
      levelId: levelId,
      title: map['title'] as String? ?? '',
      order: map['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'order': order};
  }
}
