import 'package:flutter/material.dart';

class ThemeUtils {
  static IconData getThemeIcon(String key) {
    switch (key.toLowerCase()) {
      case 'fantasy': return Icons.auto_awesome;
      case 'sci-fi': return Icons.rocket_launch;
      case 'mystery': return Icons.search;
      case 'horror': return Icons.local_fire_department; // or something scary (skull not in default set or maybe named differently?)
      case 'steampunk': return Icons.settings;
      case 'cyberpunk': return Icons.memory;
      case 'historical': return Icons.history_edu;
      case 'post-apocalyptic': return Icons.warning;
      case 'western': return Icons.explore; 
      default: return Icons.category;
    }
  }

  static Color getThemeColor(String key, BuildContext context) {
      // Optional: returns a specific color for the theme or defaults to primary
      // For now just return primary or a hashed color
      return Theme.of(context).primaryColor;
  }
}
