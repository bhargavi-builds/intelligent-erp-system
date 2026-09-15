import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Intelligent ERP Multi-Platform API Configuration
/// Automatically resolves host according to target platform (Android, iOS, Web, macOS, Windows, Linux)
class ApiConfig {
  /// Custom server override (e.g. if testing on a real physical phone over local Wi-Fi)
  /// e.g. 'http://192.168.1.50:5050'
  static String? customBaseUrl;

  /// Default port for the local Express / Supabase gateway
  static const int port = 5050;

  /// Dynamically resolved base URL
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }

    // 1. Web Browser
    if (kIsWeb) {
      return 'http://localhost:$port';
    }

    // 2. Android Emulator (uses 10.0.2.2 to access host machine)
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port';
    }

    // 3. iOS Simulator, macOS Desktop, Windows, Linux
    if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return 'http://127.0.0.1:$port';
    }

    return 'http://localhost:$port';
  }

  // Helper Endpoints
  static Uri get studentUrl => Uri.parse('$baseUrl/api/student');
  static Uri get studentAttendanceUrl => Uri.parse('$baseUrl/api/student/attendance');
  static Uri get studentAssignmentsUrl => Uri.parse('$baseUrl/api/student/assignments');
  static Uri get studentExamsUrl => Uri.parse('$baseUrl/api/student/exams');
  static Uri get studentResultsUrl => Uri.parse('$baseUrl/api/student/results');

  static Uri get facultyUrl => Uri.parse('$baseUrl/api/faculty');
  static Uri get facultyStudentsUrl => Uri.parse('$baseUrl/api/faculty/students');
  static Uri get facultyAssignmentsUrl => Uri.parse('$baseUrl/api/faculty/assignments');
  static Uri get facultyAttendanceUrl => Uri.parse('$baseUrl/api/faculty/attendance');
  static Uri get facultyAnnouncementsUrl => Uri.parse('$baseUrl/api/faculty/announcements');

  static Uri get parentUrl => Uri.parse('$baseUrl/api/parent');
  static Uri get parentFeesUrl => Uri.parse('$baseUrl/api/parent/fees');

  static Uri get adminSummaryUrl => Uri.parse('$baseUrl/api/admin/summary');
  static Uri get adminStudentsUrl => Uri.parse('$baseUrl/api/admin/students');
  static Uri get adminFacultyUrl => Uri.parse('$baseUrl/api/admin/faculty');
  static Uri get adminAnnouncementsUrl => Uri.parse('$baseUrl/api/admin/announcements');

  static Uri get announcementsUrl => Uri.parse('$baseUrl/api/announcements');
  static Uri get loginUrl => Uri.parse('$baseUrl/api/auth/login');
}
