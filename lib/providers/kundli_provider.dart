import 'package:flutter/material.dart';
import '../services/astrozen_api_service.dart';

class KundliProvider extends ChangeNotifier {
  bool _isGenerating = false;
  Map<String, dynamic>? _kundliData;
  Map<String, dynamic>? _lastMatchResult;

  bool get isGenerating => _isGenerating;
  Map<String, dynamic>? get kundliData => _kundliData;
  Map<String, dynamic>? get lastMatchResult => _lastMatchResult;

  Future<Map<String, dynamic>> generateKundli({
    required String name,
    required String dob,
    required String timeOfBirth,
    required String placeOfBirth,
  }) async {
    _isGenerating = true;
    notifyListeners();

    try {
      _kundliData = await AstrozenApiService.calculateKundli(
        name: name,
        dob: dob,
        timeOfBirth: timeOfBirth,
        placeOfBirth: placeOfBirth,
      );
    } finally {
      _isGenerating = false;
      notifyListeners();
    }

    return _kundliData!;
  }

  Future<Map<String, dynamic>> calculateMatching({
    required String boyName,
    required String boyDob,
    required String girlName,
    required String girlDob,
  }) async {
    _isGenerating = true;
    notifyListeners();

    try {
      final matchData = await AstrozenApiService.calculateMatching(
        boyName: boyName,
        boyDob: boyDob,
        girlName: girlName,
        girlDob: girlDob,
      );
      _lastMatchResult = matchData;
      return matchData;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
