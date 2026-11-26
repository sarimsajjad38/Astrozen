import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/kundli_provider.dart';
import '../../widgets/common/star_background.dart';

class KundliScreen extends StatefulWidget {
  final bool isTab;
  const KundliScreen({super.key, this.isTab = false});

  @override
  State<KundliScreen> createState() => _KundliScreenState();
}

class _KundliScreenState extends State<KundliScreen> {
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _timeCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 6, 15),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.royalPurple,
            surface: AppTheme.cardBg,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        _dobCtrl.text = '${d.day}/${d.month}/${d.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.royalPurple,
            surface: AppTheme.cardBg,
          ),
        ),
        child: child!,
      ),
    );
    if (t != null) {
      setState(() {
        _timeCtrl.text = t.format(context);
      });
    }
  }

  Future<void> _generateKundli() async {
    if (_nameCtrl.text.isEmpty || _dobCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill Name and Date of Birth')),
      );
      return;
    }
    final data = await context.read<KundliProvider>().generateKundli(
      name: _nameCtrl.text,
      dob: _dobCtrl.text,
      timeOfBirth: _timeCtrl.text.isEmpty ? '12:00 PM' : _timeCtrl.text,
      placeOfBirth: _placeCtrl.text.isEmpty
          ? 'New Delhi, India'
          : _placeCtrl.text,
    );
    if (mounted) context.push('/kundli/result', extra: data);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<KundliProvider>().isGenerating;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (!widget.isTab) const StarBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
                    children: [
                      if (!widget.isTab) ...[
                        GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBgLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      const Icon(
                        Icons.menu_book_rounded,
                        color: AppTheme.starGold,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Vedic Kundli Generator',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Intro Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.celestialTeal.withValues(alpha: 0.15),
                          AppTheme.cardBg,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.celestialTeal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.celestialTeal.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: AppTheme.celestialTeal,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Precision Astral Mapping',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Computes planetary coordinates, Lagna, Navamsa, and active Mahadasha cycles.',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Name
                  Text(
                    'Full Name',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: AppTheme.starGold,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // DOB
                  Text(
                    'Date of Birth',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dobCtrl,
                        style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'DD/MM/YYYY',
                          prefixIcon: Icon(
                            Icons.calendar_today_rounded,
                            color: AppTheme.starGold,
                            size: 20,
                          ),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Time & Place in row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Birth Time',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickTime,
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: _timeCtrl,
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '12:00 PM',
                                    prefixIcon: Icon(
                                      Icons.access_time_rounded,
                                      color: AppTheme.starGold,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Birth Location',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _placeCtrl,
                              style: GoogleFonts.outfit(
                                color: AppTheme.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'City, Country',
                                prefixIcon: Icon(
                                  Icons.location_on_outlined,
                                  color: AppTheme.starGold,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Submit CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _generateKundli,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.celestialTeal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Calculating Vedic Ephemeris...',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Generate Birth Chart',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/kundli/matching'),
                      icon: const Icon(Icons.favorite_border_rounded, size: 16),
                      label: const Text('Match Kundlis (36 Guna Milan)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.starGold,
                        side: BorderSide(
                          color: AppTheme.starGold.withValues(alpha: 0.4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
