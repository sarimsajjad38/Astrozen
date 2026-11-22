import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppConstants {
  // ── Zodiac Signs ───────────────────────────────────────────────
  static const List<Map<String, dynamic>> zodiacSigns = [
    {
      'name': 'Aries',
      'symbol': '♈',
      'element': 'Fire',
      'dateRange': 'Mar 21 – Apr 19',
      'color': 0xFFFF4757,
      'icon': FontAwesomeIcons.fire,
    },
    {
      'name': 'Taurus',
      'symbol': '♉',
      'element': 'Earth',
      'dateRange': 'Apr 20 – May 20',
      'color': 0xFF2ED573,
      'icon': FontAwesomeIcons.mountain,
    },
    {
      'name': 'Gemini',
      'symbol': '♊',
      'element': 'Air',
      'dateRange': 'May 21 – Jun 20',
      'color': 0xFFFFD700,
      'icon': FontAwesomeIcons.wind,
    },
    {
      'name': 'Cancer',
      'symbol': '♋',
      'element': 'Water',
      'dateRange': 'Jun 21 – Jul 22',
      'color': 0xFF00B4D8,
      'icon': FontAwesomeIcons.water,
    },
    {
      'name': 'Leo',
      'symbol': '♌',
      'element': 'Fire',
      'dateRange': 'Jul 23 – Aug 22',
      'color': 0xFFFFA502,
      'icon': FontAwesomeIcons.sun,
    },
    {
      'name': 'Virgo',
      'symbol': '♍',
      'element': 'Earth',
      'dateRange': 'Aug 23 – Sep 22',
      'color': 0xFF7BED9F,
      'icon': FontAwesomeIcons.leaf,
    },
    {
      'name': 'Libra',
      'symbol': '♎',
      'element': 'Air',
      'dateRange': 'Sep 23 – Oct 22',
      'color': 0xFFFF6B9D,
      'icon': FontAwesomeIcons.scaleBalanced,
    },
    {
      'name': 'Scorpio',
      'symbol': '♏',
      'element': 'Water',
      'dateRange': 'Oct 23 – Nov 21',
      'color': 0xFFB31212,
      'icon': FontAwesomeIcons.boltLightning,
    },
    {
      'name': 'Sagittarius',
      'symbol': '♐',
      'element': 'Fire',
      'dateRange': 'Nov 22 – Dec 21',
      'color': 0xFFFF7F50,
      'icon': FontAwesomeIcons.compass,
    },
    {
      'name': 'Capricorn',
      'symbol': '♑',
      'element': 'Earth',
      'dateRange': 'Dec 22 – Jan 19',
      'color': 0xFF747D8C,
      'icon': FontAwesomeIcons.shieldHalved,
    },
    {
      'name': 'Aquarius',
      'symbol': '♒',
      'element': 'Air',
      'dateRange': 'Jan 20 – Feb 18',
      'color': 0xFF5352ED,
      'icon': FontAwesomeIcons.droplet,
    },
    {
      'name': 'Pisces',
      'symbol': '♓',
      'element': 'Water',
      'dateRange': 'Feb 19 – Mar 20',
      'color': 0xFF70A1FF,
      'icon': FontAwesomeIcons.moon,
    },
  ];

  // ── Planets ────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> planets = [
    {'name': 'Sun',     'symbol': '☉', 'icon': Icons.wb_sunny_rounded},
    {'name': 'Moon',    'symbol': '☽', 'icon': Icons.nightlight_round},
    {'name': 'Mars',    'symbol': '♂', 'icon': Icons.flare_rounded},
    {'name': 'Mercury', 'symbol': '☿', 'icon': Icons.air_rounded},
    {'name': 'Jupiter', 'symbol': '♃', 'icon': Icons.stars_rounded},
    {'name': 'Venus',   'symbol': '♀', 'icon': Icons.favorite_rounded},
    {'name': 'Saturn',  'symbol': '♄', 'icon': Icons.blur_circular_rounded},
    {'name': 'Rahu',    'symbol': '☊', 'icon': Icons.dark_mode_rounded},
    {'name': 'Ketu',    'symbol': '☋', 'icon': Icons.auto_awesome_rounded},
  ];

  // ── Houses ─────────────────────────────────────────────────────
  static const List<String> houseNames = [
    'Self & Personality', 'Wealth & Family', 'Siblings & Communication',
    'Home & Mother', 'Education & Children', 'Health & Enemies',
    'Marriage & Partnership', 'Longevity & Inheritance', 'Luck & Wisdom',
    'Career & Status', 'Friends & Gains', 'Losses & Spirituality',
  ];

  // ── Subscription Plans ─────────────────────────────────────────
  static const Map<String, dynamic> trialPlan = {
    'name': 'AstroZen Trial',
    'price': 11,
    'duration': '7 Days',
    'features': [
      'Full Kundli Report',
      'Daily Horoscope Forecast',
      'AI Palm Analysis (3 scans)',
      'Vastu Direction Analysis',
      'Expert Astrologer Session (10 min)',
    ],
  };

  static const Map<String, dynamic> monthlyPlan = {
    'name': 'AstroZen Monthly',
    'price': 99,
    'duration': '1 Month',
    'features': [
      'All Trial Features Included',
      'Unlimited Kundli Calculations',
      'Unlimited AI Palm Scans',
      'Detailed Tarot Card Readings',
      'Complete Numerology Blueprint',
      'Priority Astrologer Chat',
      'Downloadable PDF Reports',
    ],
  };

  static const Map<String, dynamic> annualPlan = {
    'name': 'AstroZen Annual',
    'price': 699,
    'duration': '1 Year',
    'features': [
      'All Monthly Features Included',
      'AI 12-Month Yearly Prediction',
      'Gemstone Recommendation Engine',
      'Auspicious Muhurat Finder',
      '30 Min Astrologer Session Included',
      'Exclusive Member Events & Discounts',
    ],
  };

  // ── Expert Specializations ─────────────────────────────────────
  static const List<String> expertSpecializations = [
    'Vedic Astrology', 'Numerology', 'Tarot Reading',
    'Palm Reading', 'Vastu Shastra', 'KP Astrology',
    'Lal Kitab', 'Nadi Astrology',
  ];

  // ── Vastu Directions ───────────────────────────────────────────
  static const List<Map<String, dynamic>> vastuDirections = [
    {'dir': 'North',     'ruler': 'Kuber',    'element': 'Water', 'good': 'Money, Storage, Study'},
    {'dir': 'NorthEast', 'ruler': 'Ishaan',   'element': 'Space', 'good': 'Prayer room, Entrance'},
    {'dir': 'East',      'ruler': 'Indra',    'element': 'Air',   'good': 'Entrance, Living Room'},
    {'dir': 'SouthEast', 'ruler': 'Agni',     'element': 'Fire',  'good': 'Kitchen, Electronics'},
    {'dir': 'South',     'ruler': 'Yama',     'element': 'Earth', 'good': 'Master Bedroom'},
    {'dir': 'SouthWest', 'ruler': 'Niriti',   'element': 'Earth', 'good': 'Bedroom, Heavy items'},
    {'dir': 'West',      'ruler': 'Varuna',   'element': 'Water', 'good': 'Children room, Study'},
    {'dir': 'NorthWest', 'ruler': 'Vaayu',    'element': 'Air',   'good': 'Guest room, Garage'},
  ];
}
