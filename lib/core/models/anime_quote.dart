class AnimeQuote {
  final String content;
  final String animeName;
  final String characterName;

  const AnimeQuote({
    required this.content,
    required this.animeName,
    required this.characterName,
  });

  factory AnimeQuote.fromJson(Map<String, dynamic> json) {
    return AnimeQuote(
      content: json['data']['content'],
      animeName: json['data']['anime']['name'],
      characterName: json['data']['character']['name'],
    );
  }
}
