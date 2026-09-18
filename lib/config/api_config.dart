import 'package:shared_preferences/shared_preferences.dart';

/// Intelligent ERP Multi-Platform API Configuration
/// Automatically resolves host according to target platform (Android, iOS, Web, macOS, Windows, Linux)
/// and supports physical mobile devices over local Wi-Fi.
class ApiConfig {
  /// Custom server override (e.g. if developer wants to test on a local IP)
  static String? customBaseUrl;

  /// Default port for the local Express gateway if testing locally
  static const int port = 5050;

  /// Live production cloud backend hosted on Render
  static const String defaultCloudUrl = 'https://hitamerp.onrender.com';

  /// Default local Wi-Fi IP address of the development host machine (fallback)
  static const String defaultLocalIp = '10.192.165.225';

  /// Standard network request timeout (15s to handle Render free-tier cold starts)
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Key for SharedPreferences
  static const String _prefKey = 'intelligent_erp_custom_server_ip_v2';

  /// Initialize API config from local storage (called at app launch)
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString(_prefKey);
      if (savedIp != null && savedIp.trim().isNotEmpty) {
        setCustomServerIp(savedIp.trim(), saveToPrefs: false);
      }
    } catch (_) {
      // Graceful ignore if SharedPreferences is unavailable
    }
  }

  /// Sets or clears a custom server IP or full URL
  static Future<void> setCustomServerIp(String? hostOrUrl, {bool saveToPrefs = true}) async {
    if (hostOrUrl == null || hostOrUrl.trim().isEmpty) {
      customBaseUrl = null;
      if (saveToPrefs) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_prefKey);
        } catch (_) {}
      }
      return;
    }

    String cleaned = hostOrUrl.trim();
    if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
      // If port is not specified, append default port
      if (!cleaned.contains(':')) {
        cleaned = 'http://$cleaned:$port';
      } else {
        cleaned = 'http://$cleaned';
      }
    }

    // Strip trailing slash
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }

    customBaseUrl = cleaned;

    if (saveToPrefs) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, cleaned);
      } catch (_) {}
    }
  }

  /// Dynamically resolved base URL
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }

    // Default to the live Render cloud deployment so anyone around the world can use the app!
    return defaultCloudUrl;
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
