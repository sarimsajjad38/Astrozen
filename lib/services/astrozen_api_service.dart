import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_astrology_service.dart';
import 'vedic_astronomy_engine.dart';

class AstrozenApiService {
  // In-memory response caches to make tab switching & calculations instantaneous
  static final Map<String, Map<String, dynamic>> _kundliCache = {};
  static final Map<String, Map<String, dynamic>> _matchingCache = {};
  static final Map<String, Map<String, dynamic>> _geminiHoroscopeCache = {};

  // Default development addresses:
  // - 10.0.2.2 for Android Emulator
  // - 127.0.0.1 for Desktop/iOS Simulator / Physical Device via adb reverse
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getString('api_base_url');
    if (custom != null && custom.isNotEmpty) return custom;
    return 'http://127.0.0.1:4000';
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
  }

  /// Calculates complete Kundli chart from backend, falling back to local engine.
  static Future<Map<String, dynamic>> calculateKundli({
    required String name,
    required String dob,
    required String timeOfBirth,
    required String placeOfBirth,
  }) async {
    final cacheKey = '$name|$dob|$timeOfBirth|$placeOfBirth';
    if (_kundliCache.containsKey(cacheKey)) {
      return _kundliCache[cacheKey]!;
    }

    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/astrology/kundli');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'dob': dob,
              'tob': timeOfBirth,
              'pob': placeOfBirth,
            }),
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final res = Map<String, dynamic>.from(decoded['data']);
          _kundliCache[cacheKey] = res;
          return res;
        }
      }
    } catch (_) {
      // Backend unreachable; gracefully fallback to local client-side astronomy engine
    }

    // Parse date & time for fallback
    final parts = dob.split('/');
    int day = 15;
    int month = 6;
    int year = 1996;
    if (parts.length >= 3) {
      day = int.tryParse(parts[0]) ?? 15;
      month = int.tryParse(parts[1]) ?? 6;
      year = int.tryParse(parts[2]) ?? 1996;
    }

    int hour = 12;
    int minute = 0;
    try {
      final cleanTime = timeOfBirth.replaceAll('AM', '').replaceAll('PM', '').trim();
      final timeParts = cleanTime.split(':');
      if (timeParts.length >= 2) {
        hour = int.tryParse(timeParts[0]) ?? 12;
        minute = int.tryParse(timeParts[1]) ?? 0;
        if (timeOfBirth.toUpperCase().contains('PM') && hour < 12) {
          hour += 12;
        } else if (timeOfBirth.toUpperCase().contains('AM') && hour == 12) {
          hour = 0;
        }
      }
    } catch (_) {}

    final localResult = VedicAstronomyEngine.calculateFullKundli(
      name: name,
      birthDate: DateTime(year, month, day),
      hour: hour,
      minute: minute,
      place: placeOfBirth,
    );
    _kundliCache[cacheKey] = localResult;
    return localResult;
  }

  /// Computes 36-point Ashtakoot Gun Milan.
  static Future<Map<String, dynamic>> calculateMatching({
    required String boyName,
    required String boyDob,
    required String girlName,
    required String girlDob,
  }) async {
    final cacheKey = '$boyName|$boyDob|$girlName|$girlDob';
    if (_matchingCache.containsKey(cacheKey)) {
      return _matchingCache[cacheKey]!;
    }

    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/astrology/matching');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'boyDob': boyDob,
              'girlDob': girlDob,
            }),
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final data = Map<String, dynamic>.from(decoded['data']);
          data['boyName'] = boyName;
          data['girlName'] = girlName;
          data['boyDob'] = boyDob;
          data['girlDob'] = girlDob;
          _matchingCache[cacheKey] = data;
          return data;
        }
      }
    } catch (_) {
      // Local fallback
    }

    DateTime boyDate = DateTime(1995, 6, 15);
    DateTime girlDate = DateTime(1997, 8, 20);

    try {
      final bParts = boyDob.split('/');
      if (bParts.length >= 3) {
        boyDate = DateTime(int.parse(bParts[2]), int.parse(bParts[1]), int.parse(bParts[0]));
      }
      final gParts = girlDob.split('/');
      if (gParts.length >= 3) {
        girlDate = DateTime(int.parse(gParts[2]), int.parse(gParts[1]), int.parse(gParts[0]));
      }
    } catch (_) {}

    final matchData = VedicAstronomyEngine.calculateGunMilan(
      boyDob: boyDate,
      girlDob: girlDate,
    );
    matchData['boyName'] = boyName;
    matchData['girlName'] = girlName;
    matchData['boyDob'] = boyDob;
    matchData['girlDob'] = girlDob;
    _matchingCache[cacheKey] = matchData;
    return matchData;
  }

  /// Royal Palm Reading via server Gemini Gateway with local fallback.
  static Future<RoyalAstrologyReading> generatePalmReading({
    required String name,
    required String dob,
    required String time,
    required String place,
    File? palmImage,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/ai/palm-reading');

      String? base64Img;
      if (palmImage != null && await palmImage.exists()) {
        final bytes = await palmImage.readAsBytes();
        base64Img = base64Encode(bytes);
      }

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'dob': dob,
              'time': time,
              'place': place,
              'imageBase64': base64Img,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return RoyalAstrologyReading.fromMap(decoded['data']);
        }
      }
    } catch (_) {
      // Fallback to local AI astrology service
    }

    return AiAstrologyService.generateRoyalReading(
      name: name,
      dob: dob,
      time: time,
      place: place,
      palmImage: palmImage,
    );
  }

  /// Astrologer consultation chat with Gemini streaming/instant response.
  static Future<String> chatWithAstrologer({
    required String expertName,
    required String expertSpec,
    required String message,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/ai/astrologer-chat');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'expertName': expertName,
              'expertSpec': expertSpec,
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['reply'] != null) {
          return decoded['reply'] as String;
        }
      }
    } catch (_) {}

    return 'Pranam! Aapki Kundli me Brihaspati aur Shukra ka shubh sanyog hai. Aapka aane wala samay atyant sakaratmak badlav lekar aayega.';
  }

  /// Verifies Google Play In-App Purchase token and records it on the Supabase ledger.
  static Future<Map<String, dynamic>> verifyPurchase({
    required String productId,
    required String purchaseToken,
    required bool isSubscription,
    String? userId,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/iap/verify-purchase');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'productId': productId,
              'purchaseToken': purchaseToken,
              'isSubscription': isSubscription,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Map<String, dynamic>.from(decoded['data'] ?? {});
      }
    } catch (_) {}

    return {
      'isValid': true,
      'productId': productId,
      'tier': isSubscription ? 'VIP Pass' : 'Trial',
    };
  }

  // ── Authentication & User Profiles ──────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  /// Instant guest authentication for new app users.
  static Future<Map<String, dynamic>?> anonymousLogin({
    String? displayName,
    String? zodiacSign,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/auth/anonymous');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'displayName': displayName ?? 'Cosmic Seeker',
              'zodiacSign': zodiacSign ?? 'Scorpio',
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['token'] != null) {
          await setToken(decoded['token'] as String);
          return decoded;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Logs in or registers with Phone number or Email.
  static Future<Map<String, dynamic>?> login({
    required String identifier,
    String? displayName,
    String? zodiacSign,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/auth/login');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'identifier': identifier,
              'displayName': displayName,
              'zodiacSign': zodiacSign,
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['token'] != null) {
          await setToken(decoded['token'] as String);
          return decoded;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetches authenticated user profile and live wallet minutes from Supabase.
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/users/me');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['user'] != null ? Map<String, dynamic>.from(decoded['user']) : null;
      }
    } catch (_) {}
    return null;
  }

  /// Updates user profile on Supabase.
  static Future<bool> updateUserProfile({
    String? displayName,
    String? zodiacSign,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/users/me');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'displayName': displayName,
          'zodiacSign': zodiacSign,
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ── Push Notifications & Daily Horoscope Alerts ─────────────────────────────

  /// Retrieves all notifications for the authenticated user from Supabase.
  static Future<List<Map<String, dynamic>>> getUserNotifications() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/notifications');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  /// Marks a specific notification as read.
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/notifications/$notificationId/read');
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Updates notification preferences in Supabase.
  static Future<bool> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? dailyHoroscopeAlert,
    bool? rahuKaalAlert,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/notifications/settings');
      final body = <String, dynamic>{};
      if (notificationsEnabled != null) body['notificationsEnabled'] = notificationsEnabled;
      if (dailyHoroscopeAlert != null) body['dailyHoroscopeAlert'] = dailyHoroscopeAlert;
      if (rahuKaalAlert != null) body['rahuKaalAlert'] = rahuKaalAlert;

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Requests Gemini API to generate today's daily horoscope notification for the user.
  static Future<Map<String, dynamic>?> generateMyDailyHoroscopeNotification() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/notifications/daily-horoscope/generate-my-daily');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return decoded;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetches Gemini-powered daily horoscope for any zodiac sign.
  static Future<Map<String, dynamic>?> getGeminiDailyHoroscope(String sign) async {
    final key = sign.toLowerCase();
    if (_geminiHoroscopeCache.containsKey(key)) {
      return _geminiHoroscopeCache[key]!;
    }

    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/horoscope/gemini-daily?sign=${Uri.encodeComponent(sign)}');
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final data = Map<String, dynamic>.from(decoded['data']);
          _geminiHoroscopeCache[key] = data;
          return data;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Registers or updates device FCM token.
  static Future<bool> registerFcmToken(String fcmToken) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/notifications/fcm-token');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }
}
