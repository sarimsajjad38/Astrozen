import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/astrozen_api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _userName;
  String? _userPhone;
  String? _userZodiac;
  String? _userDob;
  String? _userTob;
  String? _userPob;
  String? _userGender;
  String? _userNakshatra;
  bool _hasCompletedHoroscopeProfile = false;
  int _walletMinutes = 5;
  bool _isSubscribed = false;
  String? _subscriptionTier;
  Map<String, dynamic>? _userBirthDetails;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userPhone => _userPhone;
  String? get userZodiac => _userZodiac;
  String? get userDob => _userDob;
  String? get userTob => _userTob;
  String? get userPob => _userPob;
  String? get userGender => _userGender;
  String? get userNakshatra => _userNakshatra;
  bool get hasCompletedHoroscopeProfile => _hasCompletedHoroscopeProfile;
  int get walletMinutes => _walletMinutes;
  bool get isSubscribed => _isSubscribed;
  String? get subscriptionTier => _subscriptionTier;
  Map<String, dynamic>? get userBirthDetails => _userBirthDetails;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _userPhone = prefs.getString('userPhone');
    _userZodiac = prefs.getString('userZodiac');
    _userDob = prefs.getString('userDob');
    _userTob = prefs.getString('userTob');
    _userPob = prefs.getString('userPob');
    _userGender = prefs.getString('userGender');
    _userNakshatra = prefs.getString('userNakshatra');
    _hasCompletedHoroscopeProfile =
        prefs.getBool('hasCompletedHoroscopeProfile') ??
            (_userDob != null && _userDob!.isNotEmpty);
    _walletMinutes = prefs.getInt('walletMinutes') ?? 5;
    _isSubscribed = prefs.getBool('isSubscribed') ?? false;
    _subscriptionTier = prefs.getString('subscriptionTier') ?? 'Free';

    if (_userDob != null) {
      _userBirthDetails = {
        'name': _userName,
        'dob': _userDob,
        'tob': _userTob,
        'pob': _userPob,
        'gender': _userGender,
        'zodiac': _userZodiac,
        'nakshatra': _userNakshatra,
      };
    }

    notifyListeners();

    // Non-blocking background sync with backend
    _syncBackendSession();
  }

  void _syncBackendSession() async {
    try {
      final token = await AstrozenApiService.getToken();
      if (token == null) {
        final guest = await AstrozenApiService.anonymousLogin(
          displayName: _userName,
          zodiacSign: _userZodiac,
        );
        if (guest != null && guest['user'] != null) {
          _applyUserData(guest['user']);
        }
      } else {
        final profile = await AstrozenApiService.getUserProfile();
        if (profile != null) {
          _applyUserData(profile);
        }
      }
    } catch (_) {}
  }

  void _applyUserData(Map<String, dynamic> data) async {
    _userId = data['id'] as String?;
    if (data['displayName'] != null) _userName = data['displayName'] as String;
    if (data['zodiacSign'] != null) _userZodiac = data['zodiacSign'] as String;
    if (data['walletMinutes'] != null) _walletMinutes = (data['walletMinutes'] as num).toInt();
    if (data['isSubscribed'] != null) _isSubscribed = data['isSubscribed'] as bool;
    if (data['subscriptionTier'] != null) _subscriptionTier = data['subscriptionTier'] as String;

    final prefs = await SharedPreferences.getInstance();
    if (_userId != null) await prefs.setString('userId', _userId!);
    if (_userName != null) await prefs.setString('userName', _userName!);
    if (_userZodiac != null) await prefs.setString('userZodiac', _userZodiac!);
    await prefs.setInt('walletMinutes', _walletMinutes);
    await prefs.setBool('isSubscribed', _isSubscribed);
    if (_subscriptionTier != null) await prefs.setString('subscriptionTier', _subscriptionTier!);

    notifyListeners();
  }

  Future<void> login(String phone, String name) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = true;
    _userName = name.trim().isEmpty ? 'Cosmic Seeker' : name.trim();
    _userPhone = phone;

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', _userName!);
    await prefs.setString('userPhone', phone);
    notifyListeners();

    try {
      final res = await AstrozenApiService.login(
        identifier: phone,
        displayName: _userName,
        zodiacSign: _userZodiac,
      );
      if (res != null && res['user'] != null) {
        _applyUserData(res['user']);
      }
    } catch (_) {}
  }

  Future<void> updateProfile({String? name, String? zodiac}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      _userName = name;
      await prefs.setString('userName', name);
    }
    if (zodiac != null) {
      _userZodiac = zodiac;
      await prefs.setString('userZodiac', zodiac);
    }
    notifyListeners();

    try {
      await AstrozenApiService.updateUserProfile(
        displayName: name,
        zodiacSign: zodiac,
      );
    } catch (_) {}
  }

  Future<void> setUserBirthDetails(Map<String, dynamic> details) async {
    _userBirthDetails = details;
    _userZodiac = details['zodiac'] as String?;
    final prefs = await SharedPreferences.getInstance();
    if (_userZodiac != null) {
      await prefs.setString('userZodiac', _userZodiac!);
    }
    notifyListeners();

    try {
      if (_userZodiac != null) {
        await AstrozenApiService.updateUserProfile(zodiacSign: _userZodiac);
      }
    } catch (_) {}
  }

  Future<void> saveHoroscopeProfile({
    required String name,
    required String dob,
    required String tob,
    required String pob,
    required String gender,
    required String zodiac,
    String? nakshatra,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _userName = name.trim();
    _userDob = dob.trim();
    _userTob = tob.trim();
    _userPob = pob.trim();
    _userGender = gender.trim();
    _userZodiac = zodiac.trim();
    _userNakshatra = nakshatra?.trim();
    _hasCompletedHoroscopeProfile = true;

    await prefs.setString('userName', _userName!);
    await prefs.setString('userDob', _userDob!);
    await prefs.setString('userTob', _userTob!);
    await prefs.setString('userPob', _userPob!);
    await prefs.setString('userGender', _userGender!);
    await prefs.setString('userZodiac', _userZodiac!);
    if (_userNakshatra != null) {
      await prefs.setString('userNakshatra', _userNakshatra!);
    }
    await prefs.setBool('hasCompletedHoroscopeProfile', true);

    _userBirthDetails = {
      'name': _userName,
      'dob': _userDob,
      'tob': _userTob,
      'pob': _userPob,
      'gender': _userGender,
      'zodiac': _userZodiac,
      'nakshatra': _userNakshatra,
    };

    notifyListeners();

    try {
      await AstrozenApiService.updateUserProfile(
        displayName: _userName,
        zodiacSign: _userZodiac,
      );
    } catch (_) {}
  }

  Future<void> creditSubscription(int minutes, String tier) async {
    _walletMinutes += minutes;
    _isSubscribed = true;
    _subscriptionTier = tier;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('walletMinutes', _walletMinutes);
    await prefs.setBool('isSubscribed', true);
    await prefs.setString('subscriptionTier', tier);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _userId = null;
    _userName = null;
    _userPhone = null;
    _userZodiac = null;
    _userDob = null;
    _userTob = null;
    _userPob = null;
    _userGender = null;
    _userNakshatra = null;
    _hasCompletedHoroscopeProfile = false;
    _walletMinutes = 5;
    _isSubscribed = false;
    _subscriptionTier = 'Free';
    notifyListeners();
  }
}
