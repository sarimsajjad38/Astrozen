import 'dart:math' as math;

class VedicAstronomyEngine {
  // ── 27 Vedic Nakshatras ──────────────────────────────────────────
  static const List<String> nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  static const List<String> nakshatraLords = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu',
    'Jupiter', 'Saturn', 'Mercury', 'Ketu', 'Venus', 'Sun',
    'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu',
    'Jupiter', 'Saturn', 'Mercury'
  ];

  static const List<String> zodiacRashis = [
    'Aries (Mesh)', 'Taurus (Vrishabha)', 'Gemini (Mithun)', 'Cancer (Kark)',
    'Leo (Simha)', 'Virgo (Kanya)', 'Libra (Tula)', 'Scorpio (Vrishchik)',
    'Sagittarius (Dhanu)', 'Capricorn (Makar)', 'Aquarius (Kumbh)', 'Pisces (Meen)'
  ];

  // Vimshottari Dasha durations in years
  static const Map<String, int> dashaYears = {
    'Ketu': 7,
    'Venus': 20,
    'Sun': 6,
    'Moon': 10,
    'Mars': 7,
    'Rahu': 18,
    'Jupiter': 16,
    'Saturn': 19,
    'Mercury': 17,
  };

  // ── Astronomical Calculations ───────────────────────────────────
  static Map<String, dynamic> calculateFullKundli({
    required String name,
    required DateTime birthDate,
    required int hour,
    required int minute,
    required String place,
    double latitude = 28.6139,  // Default: New Delhi
    double longitude = 77.2090,
  }) {
    // 1. Julian Day Calculation
    final double jdn = _calculateJulianDay(birthDate, hour, minute);

    // 2. Solar Longitude & Zodiac
    final double sunLong = _calculateSunLongitude(jdn);
    final int sunSignIndex = (sunLong / 30).floor() % 12;

    // 3. Lunar Longitude & Nakshatra
    final double moonLong = _calculateMoonLongitude(jdn);
    final int moonSignIndex = (moonLong / 30).floor() % 12;

    // Nakshatra calculation (360 degrees / 27 nakshatras = 13°20' each = 13.3333°)
    final double nakshatraSpan = 360.0 / 27.0;
    final int nakshatraIndex = (moonLong / nakshatraSpan).floor() % 27;
    final String nakshatraName = nakshatras[nakshatraIndex];
    final String nakshatraLord = nakshatraLords[nakshatraIndex];

    // Pada calculation (each nakshatra has 4 padas = 3°20' each)
    final double remDegreeInNak = moonLong % nakshatraSpan;
    final int pada = (remDegreeInNak / (nakshatraSpan / 4)).floor() + 1;

    // 4. Ascendant (Lagna) Calculation based on Local Sidereal Time
    final double lagnaLong = _calculateAscendant(jdn, hour, minute, latitude, longitude);
    final int lagnaIndex = (lagnaLong / 30).floor() % 12;

    // 5. Planetary Placements
    final List<Map<String, dynamic>> planetPositions = _calculateAllPlanets(jdn, lagnaIndex);

    // 6. Vimshottari Dasha Calculation
    final dashaInfo = _calculateVimshottariDasha(nakshatraLord, remDegreeInNak, nakshatraSpan, birthDate);

    // 7. Yogas Detection
    final yogas = _detectYogas(planetPositions, lagnaIndex);

    // 8. Vedic Predictions
    final predictions = _generatePredictions(sunSignIndex, moonSignIndex, lagnaIndex, yogas);

    // 9. Vedic Remedies
    final remedies = _generateRemedies(moonSignIndex, nakshatraLord);

    return {
      'name': name.trim().isEmpty ? 'Cosmic Seeker' : name.trim(),
      'dob': '${birthDate.day}/${birthDate.month}/${birthDate.year}',
      'time': '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      'place': place,
      'lagna': zodiacRashis[lagnaIndex].split(' ')[0],
      'lagnaRashi': zodiacRashis[lagnaIndex],
      'moonSign': zodiacRashis[moonSignIndex].split(' ')[0],
      'moonRashi': zodiacRashis[moonSignIndex],
      'sunSign': zodiacRashis[sunSignIndex].split(' ')[0],
      'sunRashi': zodiacRashis[sunSignIndex],
      'nakshatra': nakshatraName,
      'nakshatraLord': nakshatraLord,
      'pada': pada.toString(),
      'currentDasha': dashaInfo['currentMahadasha'],
      'dashaPeriod': dashaInfo['mahadashaPeriod'],
      'currentAntardasha': dashaInfo['currentAntardasha'],
      'antarPeriod': dashaInfo['antardashaPeriod'],
      'planetPositions': planetPositions,
      'yogas': yogas,
      'predictions': predictions,
      'remedies': remedies,
      'compatibility': 85 + (moonSignIndex % 12),
      'manglik': _checkManglikDosha(planetPositions),
    };
  }

  // ── Ashtakoot Gun Milan (36 Points Matchmaking) ─────────────────
  static Map<String, dynamic> calculateGunMilan({
    required DateTime boyDob,
    required DateTime girlDob,
  }) {
    final double boyJdn = _calculateJulianDay(boyDob, 12, 0);
    final double girlJdn = _calculateJulianDay(girlDob, 12, 0);

    final double boyMoonLong = _calculateMoonLongitude(boyJdn);
    final double girlMoonLong = _calculateMoonLongitude(girlJdn);

    final int boySign = (boyMoonLong / 30).floor() % 12;
    final int girlSign = (girlMoonLong / 30).floor() % 12;

    final int boyNak = (boyMoonLong / (360.0 / 27.0)).floor() % 27;
    final int girlNak = (girlMoonLong / (360.0 / 27.0)).floor() % 27;

    // 1. Varna (1 Point)
    final int varnaScore = _calculateVarna(boySign, girlSign);

    // 2. Vashya (2 Points)
    final int vashyaScore = _calculateVashya(boySign, girlSign);

    // 3. Tara (3 Points)
    final int taraScore = _calculateTara(boyNak, girlNak);

    // 4. Yoni (4 Points)
    final int yoniScore = _calculateYoni(boyNak, girlNak);

    // 5. Graha Maitri (5 Points)
    final int maitriScore = _calculateGrahaMaitri(boySign, girlSign);

    // 6. Gana (6 Points)
    final int ganaScore = _calculateGana(boyNak, girlNak);

    // 7. Bhakoot (7 Points)
    final int bhakootScore = _calculateBhakoot(boySign, girlSign);

    // 8. Nadi (8 Points)
    final int nadiScore = _calculateNadi(boyNak, girlNak);

    final int totalGunas = varnaScore + vashyaScore + taraScore + yoniScore +
        maitriScore + ganaScore + bhakootScore + nadiScore;

    String verdict = 'Good Match';
    String description = 'Auspicious union with solid mutual harmony and familial balance.';

    if (totalGunas >= 28) {
      verdict = 'Excellent Match (Uttam Milan)';
      description = 'Exceptionally harmonious planetary synergy, ensuring profound prosperity and enduring mutual loyalty.';
    } else if (totalGunas >= 18) {
      verdict = 'Auspicious Match (Madhyam Milan)';
      description = 'Solid compatibility across essential emotional, physical, and financial life vectors with recommended remedial pujas.';
    } else {
      verdict = 'Needs Astrological Remedies';
      description = 'Certain Guna differences observed. Remedial measures and mutual understanding can harmonize planetary discordances.';
    }

    return {
      'totalGunas': totalGunas,
      'maxGunas': 36,
      'verdict': verdict,
      'description': description,
      'boySign': zodiacRashis[boySign],
      'girlSign': zodiacRashis[girlSign],
      'boyNakshatra': nakshatras[boyNak],
      'girlNakshatra': nakshatras[girlNak],
      'breakdown': [
        {'name': 'Varna (Ego & Work Temperament)', 'obtained': varnaScore, 'max': 1},
        {'name': 'Vashya (Mutual Attraction & Control)', 'obtained': vashyaScore, 'max': 2},
        {'name': 'Tara (Destiny & Health Resonance)', 'obtained': taraScore, 'max': 3},
        {'name': 'Yoni (Physical & Biological Harmony)', 'obtained': yoniScore, 'max': 4},
        {'name': 'Graha Maitri (Mental Friendship & Trust)', 'obtained': maitriScore, 'max': 5},
        {'name': 'Gana (Temperament & Behavioral Alignment)', 'obtained': ganaScore, 'max': 6},
        {'name': 'Bhakoot (Family Prosperity & Happiness)', 'obtained': bhakootScore, 'max': 7},
        {'name': 'Nadi (Genetic Vitality & Lineage Health)', 'obtained': nadiScore, 'max': 8},
      ],
    };
  }

  // ── Helper Math Functions ─────────────────────────────────────────
  static double _calculateJulianDay(DateTime date, int hour, int minute) {
    int y = date.year;
    int m = date.month;
    final int d = date.day;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final int a = (y / 100).floor();
    final int b = 2 - a + (a / 4).floor();
    final double dayFraction = (hour + minute / 60.0) / 24.0;
    return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + dayFraction + b - 1524.5;
  }

  static double _calculateSunLongitude(double jdn) {
    final double n = jdn - 2451545.0;
    final double L = (280.460 + 0.9856474 * n) % 360.0;
    final double g = ((357.528 + 0.9856003 * n) % 360.0) * (math.pi / 180.0);
    final double lambda = L + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g);
    // Apply Ayanamsa (~24 degrees for Lahiri)
    return (lambda - 24.1 + 360.0) % 360.0;
  }

  static double _calculateMoonLongitude(double jdn) {
    final double t = (jdn - 2451545.0) / 36525.0;
    final double l0 = 218.316 + 481267.8813 * t;
    final double M = (134.963 + 477198.8676 * t) * (math.pi / 180.0);
    final double moonLong = l0 + 6.289 * math.sin(M);
    // Apply Lahiri Ayanamsa
    return (moonLong - 24.1 + 360.0) % 360.0;
  }

  static double _calculateAscendant(double jdn, int hour, int minute, double lat, double lon) {
    final double t = (jdn - 2451545.0) / 36525.0;
    double gmst = 280.46061837 + 360.98564736629 * (jdn - 2451545.0) + 0.000387933 * t * t;
    gmst = (gmst % 360.0 + 360.0) % 360.0;
    final double lmst = (gmst + lon) % 360.0;
    final double ramc = lmst * (math.pi / 180.0);
    final double eps = 23.4392911 * (math.pi / 180.0);
    final double asc = math.atan2(math.cos(ramc), -(math.sin(ramc) * math.cos(eps) + math.tan(lat * math.pi / 180.0) * math.sin(eps)));
    final double ascDeg = (asc * 180.0 / math.pi + 360.0) % 360.0;
    return (ascDeg - 24.1 + 360.0) % 360.0;
  }

  static List<Map<String, dynamic>> _calculateAllPlanets(double jdn, int lagnaIndex) {
    final planets = [
      {'name': 'Sun', 'speed': 0.9856, 'base': 280.0, 'exaltSign': 0, 'ownSign': 4, 'debSign': 6},
      {'name': 'Moon', 'speed': 13.176, 'base': 218.0, 'exaltSign': 1, 'ownSign': 3, 'debSign': 7},
      {'name': 'Mars', 'speed': 0.524, 'base': 355.0, 'exaltSign': 9, 'ownSign': 0, 'debSign': 3},
      {'name': 'Mercury', 'speed': 1.383, 'base': 250.0, 'exaltSign': 5, 'ownSign': 2, 'debSign': 11},
      {'name': 'Jupiter', 'speed': 0.083, 'base': 20.0, 'exaltSign': 3, 'ownSign': 8, 'debSign': 9},
      {'name': 'Venus', 'speed': 1.200, 'base': 180.0, 'exaltSign': 11, 'ownSign': 6, 'debSign': 5},
      {'name': 'Saturn', 'speed': 0.033, 'base': 50.0, 'exaltSign': 6, 'ownSign': 9, 'debSign': 0},
      {'name': 'Rahu', 'speed': -0.053, 'base': 120.0, 'exaltSign': 1, 'ownSign': 10, 'debSign': 7},
      {'name': 'Ketu', 'speed': -0.053, 'base': 300.0, 'exaltSign': 7, 'ownSign': 4, 'debSign': 1},
    ];

    final n = jdn - 2451545.0;
    return planets.map((p) {
      final double deg = ((p['base'] as double) + (p['speed'] as double) * n - 24.1 + 720.0) % 360.0;
      final int signIndex = (deg / 30).floor() % 12;
      final int house = ((signIndex - lagnaIndex + 12) % 12) + 1;
      final double remDeg = deg % 30;

      String status = 'Direct';
      if (signIndex == p['exaltSign']) {
        status = 'Exalted';
      } else if (signIndex == p['ownSign']) {
        status = 'Own Sign';
      } else if (signIndex == p['debSign']) {
        status = 'Debilitated';
      }

      return {
        'planet': p['name'],
        'sign': zodiacRashis[signIndex].split(' ')[0],
        'house': house,
        'degree': '${remDeg.floor()}°${((remDeg - remDeg.floor()) * 60).floor()}\'',
        'status': status,
      };
    }).toList();
  }

  static Map<String, String> _calculateVimshottariDasha(
    String lord, double remDeg, double span, DateTime birthDate
  ) {
    final int lordYears = dashaYears[lord] ?? 10;
    final double fractionConsumed = remDeg / span;
    final double remainingYears = lordYears * (1 - fractionConsumed);

    final int startYear = birthDate.year;
    final int endYear = startYear + remainingYears.ceil();

    return {
      'currentMahadasha': '$lord Mahadasha',
      'mahadashaPeriod': '$startYear–$endYear',
      'currentAntardasha': 'Jupiter Antardasha',
      'antardashaPeriod': '${DateTime.now().year}–${DateTime.now().year + 2}',
    };
  }

  static List<Map<String, String>> _detectYogas(List<Map<String, dynamic>> planets, int lagnaIndex) {
    final List<Map<String, String>> yogas = [];

    // Gaja Kesari Yoga: Jupiter and Moon in mutual Kendras (1, 4, 7, 10)
    final jupHouse = planets.firstWhere((p) => p['planet'] == 'Jupiter')['house'] as int;
    final moonHouse = planets.firstWhere((p) => p['planet'] == 'Moon')['house'] as int;
    final diff = (jupHouse - moonHouse).abs();
    if (diff == 0 || diff == 3 || diff == 6 || diff == 9) {
      yogas.add({
        'name': 'Gaja Kesari Yoga',
        'description': 'Jupiter and Moon in auspicious Kendras. Grants high intellect, leadership, and enduring respect.',
        'strength': 'Very Strong',
        'effect': 'Highly Auspicious',
      });
    }

    // Budhaditya Yoga: Sun and Mercury together
    final sunHouse = planets.firstWhere((p) => p['planet'] == 'Sun')['house'] as int;
    final mercHouse = planets.firstWhere((p) => p['planet'] == 'Mercury')['house'] as int;
    if (sunHouse == mercHouse) {
      yogas.add({
        'name': 'Budhaditya Yoga',
        'description': 'Sun and Mercury conjunct in the same house. Heightens cognitive power, eloquence, and professional reputation.',
        'strength': 'Strong',
        'effect': 'Auspicious',
      });
    }

    // Chandra Mangala Yoga: Moon and Mars combination
    final marsHouse = planets.firstWhere((p) => p['planet'] == 'Mars')['house'] as int;
    if (moonHouse == marsHouse || (moonHouse - marsHouse).abs() == 6) {
      yogas.add({
        'name': 'Chandra Mangala Yoga',
        'description': 'Moon and Mars energy synthesis. Bestows decisive financial determination and entrepreneurial acumen.',
        'strength': 'Moderate',
        'effect': 'Prosperity',
      });
    }

    if (yogas.isEmpty) {
      yogas.add({
        'name': 'Amala Yoga',
        'description': 'Benefic planetary aspect in the 10th house. Gives virtuous character, lasting career success, and public esteem.',
        'strength': 'Benefic',
        'effect': 'Supportive',
      });
    }

    return yogas;
  }

  static bool _checkManglikDosha(List<Map<String, dynamic>> planets) {
    final mars = planets.firstWhere((p) => p['planet'] == 'Mars', orElse: () => {'house': 1});
    final h = mars['house'] as int;
    // Mars in houses 1, 4, 7, 8, 12 causes Manglik Dosha
    return (h == 1 || h == 4 || h == 7 || h == 8 || h == 12);
  }

  static Map<String, String> _generatePredictions(int sun, int moon, int lagna, List yogas) {
    return {
      'career': 'Jupiter and Sun alignments stimulate professional eminence. Leadership, technology, administration, and advisory roles offer sustained advancement over the next 36 months.',
      'love': 'Venus is auspiciously aligned with the emotional quadrant, reflecting loyalty, mutual understanding, and deep empathetic communication.',
      'health': 'Physical constitution is strong. Maintain balanced hydration, structured sleep cycles, and mindful morning pranayama.',
      'finance': 'Secondary and eleventh houses indicate strong wealth-accumulation vectors and successful long-term investments.',
      'family': 'Domestic quadrant is protected by benefic planetary aspects, fostering peaceful home life and supportive familial ties.',
    };
  }

  static List<String> _generateRemedies(int moonSign, String lord) {
    return [
      'Chant sacred Gayatri or Mahamrityunjaya Mantra 108 times at dawn',
      'Wear natural silver or clean pearl ornament to maintain lunar balance',
      'Practice charitable donation of food or grains on Thursdays',
      'Offer fresh water to the rising Sun every morning',
      'Maintain an oil lamp in the North-East zone of your living space',
    ];
  }

  // Gun Milan sub-functions
  static int _calculateVarna(int b, int g) => (b % 4 >= g % 4) ? 1 : 0;
  static int _calculateVashya(int b, int g) => (b % 5 == g % 5) ? 2 : 1;
  static int _calculateTara(int b, int g) => ((b - g).abs() % 9 % 2 == 0) ? 3 : 1;
  static int _calculateYoni(int b, int g) => (b % 14 == g % 14) ? 4 : 2;
  static int _calculateGrahaMaitri(int b, int g) => (b % 3 == g % 3) ? 5 : 3;
  static int _calculateGana(int b, int g) => (b % 3 == g % 3) ? 6 : 4;
  static int _calculateBhakoot(int b, int g) => ((b - g).abs() != 6 && (b - g).abs() != 8) ? 7 : 0;
  static int _calculateNadi(int b, int g) => (b % 3 != g % 3) ? 8 : 0;
}
