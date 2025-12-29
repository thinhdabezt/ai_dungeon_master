import 'package:flutter/material.dart';

class ThemeUtils {
  static IconData getThemeIcon(String key) {
    switch (key.toLowerCase()) {
      case 'classic_high_fantasy': return Icons.castle;
      case 'grimdark_noir': return Icons.nightlight_round;
      case 'comedy_capers': return Icons.theater_comedy;
      case 'mystery_investigator': return Icons.search;
      case 'survival_horror': return Icons.warning_amber; // or dangerous
      case 'sci_fi_exploration': return Icons.rocket_launch;
      case 'mythic_eastern': return Icons.temple_buddhist; // or landscape
      case 'sword_and_sorcery': return Icons.shield;
      case 'dreamlike_surreal': return Icons.auto_awesome;
      default: return Icons.category;
    }
  }

  static Color getThemeColor(String key, BuildContext context) {
      // Optional: returns a specific color for the theme or defaults to primary
      // For now just return primary or a hashed color
      return Theme.of(context).primaryColor;
  }
}
