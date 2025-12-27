import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Desktop/Web
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5258/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5258/api';
    }
    return 'http://localhost:5258/api';
  }
}
