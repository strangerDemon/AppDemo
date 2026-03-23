class DictationWord {
  final String word;
  final String meaning;

  DictationWord({required this.word, this.meaning = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DictationWord &&
          runtimeType == other.runtimeType &&
          word == other.word;

  @override
  int get hashCode => word.hashCode;
}
