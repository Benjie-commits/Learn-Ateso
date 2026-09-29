class VocabularyItem {
  const VocabularyItem({
    required this.word,
    required this.translation,
    this.audioRef,
    required this.category,
  });

  /// PLACEHOLDER data note: `word` holds sample/placeholder Ateso text until
  /// real content is sourced (see SRS 6.1). Not verified Ateso.
  final String word;
  final String translation;
  final String? audioRef;
  final String category;

  factory VocabularyItem.fromMap(Map<String, dynamic> map) {
    return VocabularyItem(
      word: map['word'] as String? ?? '',
      translation: map['translation'] as String? ?? '',
      audioRef: map['audioRef'] as String?,
      category: map['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'translation': translation,
      'audioRef': audioRef,
      'category': category,
    };
  }
}
