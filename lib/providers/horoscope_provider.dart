import 'package:flutter/material.dart';

class HoroscopeProvider extends ChangeNotifier {
  String _selectedSign = 'Aries';
  String _selectedPeriod = 'Today';
  final bool _isLoading = false;

  String get selectedSign => _selectedSign;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;

  void selectSign(String sign) {
    _selectedSign = sign;
    notifyListeners();
  }

  void selectPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  Map<String, dynamic> getHoroscope(String sign, String period) {
    final base = _mockHoroscopes[sign] ?? _mockHoroscopes['Aries']!;
    final periodKey = period.toLowerCase().replaceAll(' ', '_');

    String reading = base['today'] as String;
    if (periodKey == 'this_week') {
      reading =
          'This week brings steady momentum and clarity. Planetary transits in your chart highlight financial growth and strong bonds. Remain adaptable to unexpected shifts mid-week.';
    } else if (periodKey == 'this_month') {
      reading =
          'A transformative month ahead. Focus on personal discipline, spiritual alignment, and long-term career aspirations. Auspicious timing favors signing new agreements after mid-month.';
    } else if (periodKey == 'yearly') {
      reading =
          'A cornerstone year for foundational progress. Major cosmic aspects support health revitalization, prosperous ventures, and harmonious relationships.';
    }

    return {...base, 'reading': reading, 'current_period': period};
  }

  final Map<String, Map<String, dynamic>> _mockHoroscopes = {
    'Aries': {
      'today':
          'The stars align powerfully in your favor today. Mars, your ruling planet, energizes your ambitions — take bold steps toward your goals. A surprise opportunity in your career could emerge. Financially, avoid impulsive spending. Your love life sparkles with renewed passion.',
      'lucky_number': '7',
      'lucky_color': 'Crimson',
      'lucky_direction': 'East',
      'lucky_gemstone': 'Red Coral',
      'mood': 'Energetic',
      'love': 85,
      'career': 90,
      'health': 75,
      'finance': 65,
      'mantra': 'Om Mangalaya Namaha',
    },
    'Taurus': {
      'today':
          'Venus blesses your day with harmony and comfort. Financial matters show positive movement — a pending deal may finally close. Your practical nature will help you navigate a tricky conversation at work. Focus on self-care and nourishment today.',
      'lucky_number': '6',
      'lucky_color': 'Emerald Green',
      'lucky_direction': 'South',
      'lucky_gemstone': 'Diamond',
      'mood': 'Calm',
      'love': 90,
      'career': 70,
      'health': 85,
      'finance': 80,
      'mantra': 'Om Shukraya Namaha',
    },
    'Gemini': {
      'today':
          'Mercury, your ruler, is in an excellent position today. Communication flows effortlessly — this is the perfect day for negotiations, presentations, or important conversations. Twins, your dual nature brings creative solutions. Stay grounded and focused.',
      'lucky_number': '5',
      'lucky_color': 'Amber Yellow',
      'lucky_direction': 'West',
      'lucky_gemstone': 'Emerald',
      'mood': 'Creative',
      'love': 70,
      'career': 95,
      'health': 70,
      'finance': 75,
      'mantra': 'Om Budhaya Namaha',
    },
    'Cancer': {
      'today':
          'The Moon, your cosmic mother, wraps you in emotional clarity today. Home and family matters take center stage. Trust your intuition — it will not mislead you. A family member may need your support. Financially, stay conservative.',
      'lucky_number': '2',
      'lucky_color': 'Pearl White',
      'lucky_direction': 'North',
      'lucky_gemstone': 'Pearl',
      'mood': 'Intuitive',
      'love': 95,
      'career': 65,
      'health': 80,
      'finance': 70,
      'mantra': 'Om Chandraya Namaha',
    },
    'Leo': {
      'today':
          'The Sun shines brilliantly upon you today, Leo. Leadership opportunities abound. Your charisma is magnetic — others are drawn to your confidence. A creative project gains momentum. Romance sizzles under this solar energy. Own the spotlight.',
      'lucky_number': '1',
      'lucky_color': 'Solar Gold',
      'lucky_direction': 'East',
      'lucky_gemstone': 'Ruby',
      'mood': 'Confident',
      'love': 80,
      'career': 95,
      'health': 85,
      'finance': 80,
      'mantra': 'Om Suryaya Namaha',
    },
    'Virgo': {
      'today':
          'Your analytical mind is at its sharpest today, Virgo. Mercury guides you to find solutions that others have missed. Health routines begun today will show lasting results. At work, your attention to detail earns praise. A financial decision requires careful analysis.',
      'lucky_number': '5',
      'lucky_color': 'Sapphire Blue',
      'lucky_direction': 'North',
      'lucky_gemstone': 'Emerald',
      'mood': 'Focused',
      'love': 65,
      'career': 90,
      'health': 90,
      'finance': 85,
      'mantra': 'Om Budhaya Namaha',
    },
    'Libra': {
      'today':
          'Venus blesses relationships today, dear Libra. Balance is your strength — use it to harmonize a tense situation. A romantic gesture will be deeply appreciated. Business partnerships show favorable developments. Beauty and art bring you joy.',
      'lucky_number': '6',
      'lucky_color': 'Rose Pink',
      'lucky_direction': 'West',
      'lucky_gemstone': 'Diamond',
      'mood': 'Harmonious',
      'love': 95,
      'career': 75,
      'health': 75,
      'finance': 70,
      'mantra': 'Om Shukraya Namaha',
    },
    'Scorpio': {
      'today':
          'Pluto and Mars intensify your perceptions today, Scorpio. Hidden truths may come to light — your investigative nature uncovers what others miss. Transformation is in the air. Trust your deep instincts in financial matters. Passion runs high.',
      'lucky_number': '9',
      'lucky_color': 'Deep Maroon',
      'lucky_direction': 'North',
      'lucky_gemstone': 'Red Coral',
      'mood': 'Intense',
      'love': 85,
      'career': 80,
      'health': 70,
      'finance': 90,
      'mantra': 'Om Mangalaya Namaha',
    },
    'Sagittarius': {
      'today':
          'Jupiter expands your horizons today, Sagittarius. An opportunity for travel or higher learning presents itself. Your optimism is contagious and attracts good fortune. A philosophical conversation leads to deep insights. Financial luck is favorable.',
      'lucky_number': '3',
      'lucky_color': 'Saffron Orange',
      'lucky_direction': 'NorthEast',
      'lucky_gemstone': 'Yellow Sapphire',
      'mood': 'Optimistic',
      'love': 80,
      'career': 85,
      'health': 90,
      'finance': 85,
      'mantra': 'Om Guruve Namaha',
    },
    'Capricorn': {
      'today':
          'Saturn rewards your discipline today, Capricorn. Long-term efforts begin to show tangible results. Career achievements are highlighted — recognition from superiors is likely. Stay patient; the mountain summit is closer than it appears.',
      'lucky_number': '8',
      'lucky_color': 'Midnight Blue',
      'lucky_direction': 'West',
      'lucky_gemstone': 'Blue Sapphire',
      'mood': 'Determined',
      'love': 65,
      'career': 95,
      'health': 75,
      'finance': 90,
      'mantra': 'Om Shanaye Namaha',
    },
    'Aquarius': {
      'today':
          'Uranus sparks innovation in your brilliant mind today, Aquarius. A revolutionary idea could change everything. Your humanitarian nature draws people who need your wisdom. Technology and science hold the key to current challenges. Be bold and original.',
      'lucky_number': '4',
      'lucky_color': 'Electric Teal',
      'lucky_direction': 'South',
      'lucky_gemstone': 'Blue Sapphire',
      'mood': 'Innovative',
      'love': 70,
      'career': 90,
      'health': 80,
      'finance': 75,
      'mantra': 'Om Shanaye Namaha',
    },
    'Pisces': {
      'today':
          'Neptune deepens your spiritual connection today, Pisces. Dreams carry important messages — keep a journal. Creative work flows with divine inspiration. Compassion and empathy are your superpowers today. Trust the universe\'s guidance.',
      'lucky_number': '7',
      'lucky_color': 'Aquamarine',
      'lucky_direction': 'NorthEast',
      'lucky_gemstone': 'Yellow Sapphire',
      'mood': 'Serene',
      'love': 90,
      'career': 70,
      'health': 75,
      'finance': 65,
      'mantra': 'Om Guruve Namaha',
    },
  };
}
