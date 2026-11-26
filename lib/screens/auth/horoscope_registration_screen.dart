import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/star_background.dart';

class HoroscopeRegistrationScreen extends StatefulWidget {
  final bool isEdit;
  const HoroscopeRegistrationScreen({super.key, this.isEdit = false});

  @override
  State<HoroscopeRegistrationScreen> createState() =>
      _HoroscopeRegistrationScreenState();
}

class _HoroscopeRegistrationScreenState
    extends State<HoroscopeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _tobCtrl;
  late final TextEditingController _pobCtrl;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedGender = 'Male';
  String _selectedZodiac = 'Scorpio';
  bool _unknownBirthTime = false;
  bool _isLoading = false;

  final List<String> _popularCities = [
    'New Delhi, India',
    'Mumbai, India',
    'Bengaluru, India',
    'Kolkata, India',
    'Hyderabad, India',
    'Chennai, India',
    'Ahmedabad, India',
    'Pune, India',
    'Jaipur, India',
    'London, UK',
    'New York, USA',
    'Dubai, UAE',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();

    _nameCtrl = TextEditingController(text: auth.userName ?? '');
    _dobCtrl = TextEditingController(text: auth.userDob ?? '');
    _tobCtrl = TextEditingController(
      text: auth.userTob ?? (auth.userDob != null ? '12:00 PM' : ''),
    );
    _pobCtrl = TextEditingController(
      text: auth.userPob ?? 'New Delhi, India',
    );
    _selectedGender = auth.userGender ?? 'Male';
    _selectedZodiac = auth.userZodiac ?? 'Scorpio';

    if (auth.userDob != null && auth.userDob!.isNotEmpty) {
      try {
        final parts = auth.userDob!.split('/');
        if (parts.length == 3) {
          _selectedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _tobCtrl.dispose();
    _pobCtrl.dispose();
    super.dispose();
  }

  String _calculateZodiacFromDate(DateTime date) {
    final m = date.month;
    final d = date.day;
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 'Aries';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 'Taurus';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'Gemini';
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 'Cancer';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 'Leo';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 'Virgo';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 'Libra';
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 'Scorpio';
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 'Sagittarius';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 'Capricorn';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 'Aquarius';
    return 'Pisces';
  }

  Future<void> _pickDate() async {
    final initial =
        _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 24));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.starGold,
              onPrimary: AppTheme.deepSpace,
              surface: AppTheme.cardBg,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
        _selectedZodiac = _calculateZodiacFromDate(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.starGold,
              onPrimary: AppTheme.deepSpace,
              surface: AppTheme.cardBg,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _unknownBirthTime = false;
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        _tobCtrl.text = '$hour:$minute $period';
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dobCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your Date of Birth'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final name =
        _nameCtrl.text.trim().isEmpty ? 'Cosmic Seeker' : _nameCtrl.text.trim();
    final dob = _dobCtrl.text.trim();
    final tob = _unknownBirthTime
        ? '12:00 PM'
        : (_tobCtrl.text.trim().isEmpty ? '12:00 PM' : _tobCtrl.text.trim());
    final pob =
        _pobCtrl.text.trim().isEmpty ? 'New Delhi, India' : _pobCtrl.text.trim();

    final auth = context.read<AuthProvider>();
    final notif = context.read<NotificationProvider>();
    await auth.saveHoroscopeProfile(
      name: name,
      dob: dob,
      tob: tob,
      pob: pob,
      gender: _selectedGender,
      zodiac: _selectedZodiac,
    );

    // Trigger instant personalized daily horoscope & native push notification
    try {
      await notif.generateTodayHoroscope();
    } catch (_) {}

    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppTheme.starGold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '✨ Cosmic Horoscope Registered for $name ($_selectedZodiac)!',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.royalPurple,
        duration: const Duration(seconds: 3),
      ),
    );

    if (widget.isEdit) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSignData = AppConstants.zodiacSigns.firstWhere(
      (s) => (s['name'] as String).toLowerCase() == _selectedZodiac.toLowerCase(),
      orElse: () => AppConstants.zodiacSigns[0],
    );

    return Scaffold(
      body: Stack(
        children: [
          const StarBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.isEdit || context.canPop())
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.cardBg.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.divider),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 40),
                        Text(
                          widget.isEdit
                              ? 'Edit Horoscope Chart'
                              : 'Horoscope Registration',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (!widget.isEdit)
                          TextButton(
                            onPressed: () => context.go('/home'),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Celestial Hero Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.royalPurple,
                            AppTheme.deepPurple,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppTheme.starGold.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.royalPurple.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.deepSpace.withValues(alpha: 0.6),
                              border: Border.all(
                                color: AppTheme.starGold,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                activeSignData['symbol'] as String,
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: AppTheme.starGold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sacred Vedic Coordinates',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Powers your daily Gemini 2.5 AI prophecies, Kundli ephemeris, and Rahu Kaal alerts.',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section: Full Name
                    _buildLabel('Full Name', Icons.person_outline_rounded),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                      decoration: _inputDecoration(
                        hintText: 'Enter your name (e.g. Rahul Sharma)',
                        icon: Icons.badge_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Section: Gender Selector
                    _buildLabel('Gender', Icons.wc_rounded),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Male', 'Female', 'Other'].map((g) {
                        final isSel = _selectedGender == g;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedGender = g),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppTheme.royalPurple
                                    : AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSel
                                      ? AppTheme.starGold
                                      : AppTheme.divider,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  g,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: isSel
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSel
                                        ? AppTheme.textPrimary
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Section: Date of Birth & Time of Birth Row
                    Row(
                      children: [
                        // Date of Birth
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date of Birth', Icons.cake_outlined),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickDate,
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: _dobCtrl,
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textPrimary,
                                    ),
                                    decoration: _inputDecoration(
                                      hintText: 'DD/MM/YYYY',
                                      icon: Icons.calendar_month_rounded,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Time of Birth
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Time of Birth', Icons.access_time_rounded),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _unknownBirthTime ? null : _pickTime,
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: _tobCtrl,
                                    enabled: !_unknownBirthTime,
                                    style: GoogleFonts.outfit(
                                      color: _unknownBirthTime
                                          ? AppTheme.textMuted
                                          : AppTheme.textPrimary,
                                    ),
                                    decoration: _inputDecoration(
                                      hintText: _unknownBirthTime
                                          ? '12:00 PM (Noon)'
                                          : 'HH:MM AM/PM',
                                      icon: Icons.schedule_rounded,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Unknown time checkbox
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Checkbox(
                          value: _unknownBirthTime,
                          activeColor: AppTheme.starGold,
                          checkColor: AppTheme.deepSpace,
                          side: const BorderSide(color: AppTheme.textMuted),
                          onChanged: (val) {
                            setState(() {
                              _unknownBirthTime = val ?? false;
                              if (_unknownBirthTime) {
                                _tobCtrl.text = '12:00 PM (Noon default)';
                              } else {
                                _tobCtrl.text = '12:00 PM';
                              }
                            });
                          },
                        ),
                        Text(
                          'I don\'t know exact birth time (Uses 12:00 PM Vedic standard)',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section: Place of Birth
                    _buildLabel('Place of Birth (City, Country)', Icons.place_outlined),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pobCtrl,
                      style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                      decoration: _inputDecoration(
                        hintText: 'e.g. New Delhi, India',
                        icon: Icons.location_on_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your birth city';
                        }
                        return null;
                      },
                    ),

                    // Quick City Suggestion Chips
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _popularCities.map((city) {
                          final isSel = _pobCtrl.text == city;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(
                                city.split(',')[0],
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: isSel
                                      ? AppTheme.deepSpace
                                      : AppTheme.textSecondary,
                                  fontWeight: isSel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              backgroundColor: isSel
                                  ? AppTheme.starGold
                                  : AppTheme.cardBg,
                              side: BorderSide(
                                color: isSel
                                    ? AppTheme.starGold
                                    : AppTheme.divider,
                              ),
                              onPressed: () {
                                setState(() => _pobCtrl.text = city);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Section: Horoscope Sign (Zodiac / Rashi)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Horoscope Zodiac Sign (Rashi)', Icons.auto_awesome_rounded),
                        if (_selectedDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.celestialTeal.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Auto-Detected',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppTheme.celestialTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Zodiac Horizontal Selector
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.zodiacSigns.length,
                        itemBuilder: (ctx, idx) {
                          final z = AppConstants.zodiacSigns[idx];
                          final name = z['name'] as String;
                          final symbol = z['symbol'] as String;
                          final element = z['element'] as String;
                          final isSel = name.toLowerCase() ==
                              _selectedZodiac.toLowerCase();

                          return GestureDetector(
                            onTap: () => setState(() => _selectedZodiac = name),
                            child: Container(
                              width: 82,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppTheme.royalPurple
                                    : AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel
                                      ? AppTheme.starGold
                                      : AppTheme.divider,
                                  width: isSel ? 1.8 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    symbol,
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: isSel
                                          ? AppTheme.starGold
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: isSel
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSel
                                          ? AppTheme.textPrimary
                                          : AppTheme.textMuted,
                                    ),
                                  ),
                                  Text(
                                    element,
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      color: isSel
                                          ? AppTheme.starGold
                                          : AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Primary Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.starGold,
                          foregroundColor: AppTheme.deepSpace,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _isLoading ? null : _submitRegistration,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.deepSpace,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.stars_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.isEdit
                                        ? 'Save & Update Horoscope'
                                        : 'Activate Daily Gemini Horoscope ✨',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.starGold),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.starGold, size: 18),
      filled: true,
      fillColor: AppTheme.cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.starGold, width: 1.5),
      ),
    );
  }
}
