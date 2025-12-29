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
      // Backend returns personaPrompt, we map it to description for now
      description: (json['description'] ?? json['personaPrompt'] ?? 'No description') as String,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
  };

  // Helper for UI (requires importing material in consuming files or treating as dynamic/int if we want to keep model pure)
  // To keep model pure, we should probably have a utility class. 
  // But let's add a simple string helper or just keep the logic in UI.
  // actually, let's keep logic in UI or a separate `ThemeUtils`.
}
