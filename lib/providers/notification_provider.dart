import 'package:flutter/material.dart';
import '../services/astrozen_api_service.dart';
import '../services/push_notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  bool _dailyHoroscopeAlert = true;
  bool _rahuKaalAlert = true;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get dailyHoroscopeAlert => _dailyHoroscopeAlert;
  bool get rahuKaalAlert => _rahuKaalAlert;

  int get unreadCount =>
      _notifications.where((n) => n['isRead'] != true).length;

  Future<void> init() async {
    // Non-blocking background fetch
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await AstrozenApiService.getUserNotifications();
      _notifications = list;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n['id'] == id);
    if (idx != -1) {
      _notifications[idx]['isRead'] = true;
      notifyListeners();
    }
    return AstrozenApiService.markNotificationAsRead(id);
  }

  Future<Map<String, dynamic>?> generateTodayHoroscope() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res =
          await AstrozenApiService.generateMyDailyHoroscopeNotification();
      if (res['notification'] != null) {
        final notifMap = Map<String, dynamic>.from(res['notification']);
        _notifications.removeWhere((n) => n['id'] == notifMap['id']);
        _notifications.insert(0, notifMap);

        // Instantly trigger real Android system push notification
        final horoscopeData = res['horoscope'] ?? notifMap['data'];
        if (horoscopeData != null && horoscopeData is Map) {
          await PushNotificationService.instance.showHoroscopeAlert(
            Map<String, dynamic>.from(horoscopeData),
          );
        } else {
          await PushNotificationService.instance.showNotification(
            title: notifMap['title'] ?? '✨ Daily Cosmic Horoscope',
            body: notifMap['body'] ??
                'Your stars have aligned with celestial energies today.',
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return res;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> updateSettings({bool? dailyHoroscope, bool? rahuKaal}) async {
    if (dailyHoroscope != null) _dailyHoroscopeAlert = dailyHoroscope;
    if (rahuKaal != null) _rahuKaalAlert = rahuKaal;
    notifyListeners();

    await AstrozenApiService.updateNotificationSettings(
      dailyHoroscopeAlert: dailyHoroscope,
      rahuKaalAlert: rahuKaal,
    );
  }
}
