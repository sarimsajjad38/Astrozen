import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/kundli_provider.dart';
import '../../widgets/common/star_background.dart';

class KundliMatchingScreen extends StatefulWidget {
  const KundliMatchingScreen({super.key});

  @override
  State<KundliMatchingScreen> createState() => _KundliMatchingScreenState();
}

class _KundliMatchingScreenState extends State<KundliMatchingScreen> {
  final _boyNameCtrl = TextEditingController(text: 'Rahul Sharma');
  final _boyDobCtrl = TextEditingController(text: '15/06/1995');
  final _girlNameCtrl = TextEditingController(text: 'Pooja Verma');
  final _girlDobCtrl = TextEditingController(text: '20/08/1997');

  Map<String, dynamic>? _matchResult;

  @override
  void dispose() {
    _boyNameCtrl.dispose();
    _boyDobCtrl.dispose();
    _girlNameCtrl.dispose();
    _girlDobCtrl.dispose();
    super.dispose();
  }

  void _calculateMatch() async {
    final provider = context.read<KundliProvider>();
    final result = await provider.calculateMatching(
      boyName: _boyNameCtrl.text,
      boyDob: _boyDobCtrl.text,
      girlName: _girlNameCtrl.text,
      girlDob: _girlDobCtrl.text,
    );
    if (mounted) {
      setState(() => _matchResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<KundliProvider>().isGenerating;

    return Scaffold(
      body: Stack(
        children: [
          const StarBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBgLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.favorite_rounded, color: AppTheme.roseGold, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Kundli Milan (Gun Matching)',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Intro Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.roseGold.withValues(alpha: 0.2),
                          AppTheme.cardBg,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.roseGold.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '36-Guna Ashtakoot matching system evaluating biological, emotional, and financial harmony between partners.',
                      style: GoogleFonts.outfit(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Boy's Details Card
                  _PartnerCard(
                    title: "Boy's Astrological Details",
                    icon: Icons.man_rounded,
                    nameCtrl: _boyNameCtrl,
                    dobCtrl: _boyDobCtrl,
                    accentColor: AppTheme.celestialTeal,
                  ),
                  const SizedBox(height: 16),

                  // Girl's Details Card
                  _PartnerCard(
                    title: "Girl's Astrological Details",
                    icon: Icons.woman_rounded,
                    nameCtrl: _girlNameCtrl,
                    dobCtrl: _girlDobCtrl,
                    accentColor: AppTheme.roseGold,
                  ),
                  const SizedBox(height: 24),

                  // Match Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _calculateMatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.royalPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Calculate 36 Guna Compatibility',
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Results Display
                  if (_matchResult != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2C0F4C), Color(0xFF131742)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Gun Milan Compatibility Score',
                            style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${_matchResult!['totalGunas']}',
                                style: GoogleFonts.outfit(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.starGold,
                                ),
                              ),
                              Text(
                                ' / 36',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.starGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              _matchResult!['verdict'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.starGold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _matchResult!['description'] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textPrimary, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ashtakoot Breakdown Table
                    Text(
                      '8-Fold Ashtakoot Breakdown',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...(_matchResult!['breakdown'] as List).map((koot) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: AppTheme.glassCard,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              koot['name'] as String,
                              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          ),
                          Text(
                            '${koot['obtained']} / ${koot['max']}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: koot['obtained'] == koot['max']
                                  ? AppTheme.successGreen
                                  : AppTheme.starGold,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final TextEditingController nameCtrl;
  final TextEditingController dobCtrl;
  final Color accentColor;

  const _PartnerCard({
    required this.title,
    required this.icon,
    required this.nameCtrl,
    required this.dobCtrl,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameCtrl,
            style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Name',
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: dobCtrl,
            style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Date of Birth (DD/MM/YYYY)',
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
