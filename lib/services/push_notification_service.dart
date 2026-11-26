import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String _channelId = 'astrozen_cosmic_alerts';
  static const String _channelName = 'AstroZen Cosmic & Horoscope Alerts';
  static const String _channelDescription =
      'Daily Gemini horoscope forecasts, planetary transits, and celestial guidance';

  /// Initialize local notification plugin and channels.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('🔔 AstroZen Notification tapped: ${response.payload}');
        },
      );

      // Create Android Notification Channel for heads-up alerts
      final androidPlatform =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlatform != null) {
        const androidChannel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        );

        await androidPlatform.createNotificationChannel(androidChannel);

        // Request runtime permission for Android 13+ (Samsung One UI 5/6, Android 13/14)
        await androidPlatform.requestNotificationsPermission();
      }

      _isInitialized = true;
      debugPrint('✨ PushNotificationService initialized successfully.');
    } catch (e) {
      debugPrint('⚠️ PushNotificationService init error: $e');
    }
  }

  /// Displays an immediate native push notification on the device.
  Future<void> showNotification({
    int id = 1001,
    required String title,
    required String body,
    String? payload,
    String? summaryText,
  }) async {
    try {
      if (!_isInitialized) await init();

      final bigTextStyle = BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: summaryText ?? 'AstroZen Celestial Update',
      );

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigTextStyle,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        ticker: title,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('⚠️ Error displaying push notification: $e');
    }
  }

  /// Directly displays today's Gemini horoscope as a system push notification.
  Future<void> showHoroscopeAlert(Map<String, dynamic> horoscope) async {
    final title = horoscope['title'] ?? '✨ Daily Cosmic Horoscope';
    final body = horoscope['notificationSnippet'] ??
        horoscope['overview'] ??
        'Your stars have aligned today. Open AstroZen to explore your horoscope.';

    final luckyColor = horoscope['luckyColor'];
    final luckyNumber = horoscope['luckyNumber'];
    final mantra = horoscope['cosmicMantra'];

    String expandedBody = body;
    if (luckyColor != null || luckyNumber != null) {
      expandedBody += '\n\n🎨 Color: $luckyColor  |  🔢 Number: $luckyNumber';
    }
    if (mantra != null) {
      expandedBody += '\n🕉️ Mantra: $mantra';
    }

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: expandedBody,
      summaryText: 'Daily Gemini Horoscope',
      payload: jsonEncode(horoscope),
    );
  }
}
