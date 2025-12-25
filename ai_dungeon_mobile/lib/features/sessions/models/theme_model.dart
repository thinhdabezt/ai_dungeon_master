class ThemeModel {
  final int id;
  final String key;
  final String name;
  final String description;
  final String imageUrl;

  ThemeModel({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id'] as int,
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}
