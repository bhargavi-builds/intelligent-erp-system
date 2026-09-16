import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Enterprise-grade Notification Service for Intelligent ERP.
/// Handles native local notifications, OS system tray banners,
/// background triggers, sound/vibration channels, and device token registration.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Stream controller to broadcast notification taps for deep linking
  final StreamController<String?> _payloadStreamController =
      StreamController<String?>.broadcast();
  Stream<String?> get onNotificationTap => _payloadStreamController.stream;

  static const String channelId = 'intelligent_erp_urgent_channel';
  static const String channelName = 'HITAM Campus Alerts & Deadlines';
  static const String channelDescription =
      'Notifications for assignments, exams, fees, and official announcements.';

  /// Initialize local and background notification handling
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android Setup: use default launcher icon
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS Setup
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Linux Setup
    final LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(
      defaultActionName: 'Open Notification',
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
          _payloadStreamController.add(response.payload);
        },
      );

      // Create Android Notification Channel
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        await androidImplementation?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
          ),
        );
      }

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully.');
    } catch (e) {
      debugPrint('NotificationService initialization failed: $e');
    }
  }

  /// Request runtime notification permissions on Android 13+ and iOS
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final bool? granted =
            await androidImplementation?.requestNotificationsPermission();
        return granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final bool? granted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final MacOSFlutterLocalNotificationsPlugin? macOSImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>();
        final bool? granted = await macOSImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return true;
  }

  /// Trigger an immediate native heads-up system banner
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
    String type = 'general',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'HITAM ERP • ${type.toUpperCase()}',
      ),
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: payload ?? type,
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  /// Simulate / trigger a delayed background notification.
  /// Allows the user to minimize the app, wait [delaySeconds], and see the native
  /// system banner appear in the OS notification shade / lock screen!
  Future<void> triggerBackgroundSimulation({
    required String title,
    required String body,
    int delaySeconds = 5,
    String? payload,
    String type = 'urgent',
  }) async {
    debugPrint(
        'Triggering background notification in $delaySeconds seconds. Minimize app now to see notification!');

    Timer(Duration(seconds: delaySeconds), () async {
      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
        payload: payload,
        type: type,
      );
    });
  }

  /// Register device token with backend API
  Future<void> registerDeviceToken({
    required String userId,
    required String token,
  }) async {
    try {
      final String platform = kIsWeb
          ? 'web'
          : defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : defaultTargetPlatform == TargetPlatform.macOS
                  ? 'macos'
                  : 'android';

      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/register-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'token': token,
          'platform': platform,
        }),
      );
      debugPrint('Device token registered with backend.');
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }

  void dispose() {
    _payloadStreamController.close();
  }
}
