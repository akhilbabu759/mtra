class TranslationPairmodel {
  final String malayalam;
  final String english;

  TranslationPairmodel({required this.malayalam, required this.english});

  factory TranslationPairmodel.fromMap(Map<String, dynamic> data) {
    return TranslationPairmodel(
      malayalam: data['malayalam'],
      english: data['english'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'malayalam': malayalam,
      'english': english,
    };
  }
}
