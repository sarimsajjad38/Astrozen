import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionProvider extends ChangeNotifier {
  bool _isSubscribed = false;
  String _currentPlan = 'free';
  DateTime? _expiryDate;

  bool get isSubscribed => _isSubscribed;
  String get currentPlan => _currentPlan;
  DateTime? get expiryDate => _expiryDate;

  bool get isTrialActive =>
      _currentPlan == 'trial' &&
      _expiryDate != null &&
      DateTime.now().isBefore(_expiryDate!);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSubscribed = prefs.getBool('sub_active') ?? false;
    _currentPlan = prefs.getString('sub_plan') ?? 'free';
    final expiryStr = prefs.getString('sub_expiry');
    if (expiryStr != null) {
      _expiryDate = DateTime.tryParse(expiryStr);
      if (_expiryDate != null && DateTime.now().isAfter(_expiryDate!)) {
        _isSubscribed = false;
        _currentPlan = 'free';
        await prefs.setBool('sub_active', false);
        await prefs.setString('sub_plan', 'free');
      }
    }
    notifyListeners();
  }

  Future<void> activateTrial() async {
    await _applySubscription('trial', const Duration(days: 7));
  }

  Future<void> activateMonthly() async {
    await _applySubscription('monthly', const Duration(days: 30));
  }

  Future<void> activateAnnual() async {
    await _applySubscription('annual', const Duration(days: 365));
  }

  Future<void> _applySubscription(String plan, Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    _isSubscribed = true;
    _currentPlan = plan;
    _expiryDate = DateTime.now().add(duration);
    await prefs.setBool('sub_active', true);
    await prefs.setString('sub_plan', plan);
    await prefs.setString('sub_expiry', _expiryDate!.toIso8601String());
    notifyListeners();
  }

  bool canAccess(String feature) {
    if (!_isSubscribed) return false;
    if (_expiryDate == null || DateTime.now().isAfter(_expiryDate!)) return false;
    return true;
  }
}
