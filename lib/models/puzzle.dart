class Puzzle {
  const Puzzle({required this.id, required this.totalPieces});

  final String id;
  final int totalPieces;

  factory Puzzle.fromMap(String id, Map<String, dynamic> map) {
    return Puzzle(id: id, totalPieces: map['totalPieces'] as int? ?? 0);
  }

  Map<String, dynamic> toMap() => {'totalPieces': totalPieces};
}
