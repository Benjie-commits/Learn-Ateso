class DialogueTurn {
  const DialogueTurn({
    required this.speaker,
    required this.line,
    this.responseOptions = const [],
    this.correctResponseIndex,
  });

  /// Who speaks this turn: 'npc' (scripted) or 'user' (player picks a response).
  final String speaker;
  final String line;
  final List<String> responseOptions;
  final int? correctResponseIndex;

  factory DialogueTurn.fromMap(Map<String, dynamic> map) {
    return DialogueTurn(
      speaker: map['speaker'] as String? ?? 'npc',
      line: map['line'] as String? ?? '',
      responseOptions: (map['responseOptions'] as List?)?.cast<String>() ?? const [],
      correctResponseIndex: map['correctResponseIndex'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speaker': speaker,
      'line': line,
      'responseOptions': responseOptions,
      'correctResponseIndex': correctResponseIndex,
    };
  }
}

class DialogueModule {
  const DialogueModule({
    required this.id,
    required this.scenario,
    required this.turns,
  });

  final String id;
  final String scenario;
  final List<DialogueTurn> turns;

  factory DialogueModule.fromMap(String id, Map<String, dynamic> map) {
    return DialogueModule(
      id: id,
      scenario: map['scenario'] as String? ?? '',
      turns: (map['turns'] as List? ?? const [])
          .map((t) => DialogueTurn.fromMap(Map<String, dynamic>.from(t as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scenario': scenario,
      'turns': turns.map((t) => t.toMap()).toList(),
    };
  }
}
