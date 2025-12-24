import 'dart:io';

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Desktop
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5258/api';
    }
    return 'http://localhost:5258/api';
  }
}
