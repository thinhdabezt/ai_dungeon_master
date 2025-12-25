class CreateSessionDto {
  final String title;
  final String themeKey;

  CreateSessionDto({
    required this.title,
    required this.themeKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'themeKey': themeKey,
    };
  }
}
