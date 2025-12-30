class CreateSessionDto {
  final String title;
  final String themeKey;
  final String ieltsBand;

  CreateSessionDto({
    required this.title,
    required this.themeKey,
    this.ieltsBand = "9.0",
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'themeKey': themeKey,
      'ieltsBand': ieltsBand,
    };
  }
}
