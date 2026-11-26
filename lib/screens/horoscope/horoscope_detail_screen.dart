import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/horoscope_provider.dart';
import '../../services/astrozen_api_service.dart';
import '../../widgets/common/star_background.dart';

class HoroscopeDetailScreen extends StatefulWidget {
  final String sign;
  const HoroscopeDetailScreen({super.key, required this.sign});

  @override
  State<HoroscopeDetailScreen> createState() => _HoroscopeDetailScreenState();
}

class _HoroscopeDetailScreenState extends State<HoroscopeDetailScreen> {
  String _selectedPeriod = 'Today';
  Map<String, dynamic>? _geminiToday;

  @override
  void initState() {
    super.initState();
    _fetchGeminiHoroscope();
  }

  void _fetchGeminiHoroscope() async {
    try {
      final res = await AstrozenApiService.getGeminiDailyHoroscope(widget.sign);
      if (mounted && res != null) {
        setState(() {
          _geminiToday = res;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final signData = AppConstants.zodiacSigns.firstWhere(
      (s) => (s['name'] as String).toLowerCase() == widget.sign.toLowerCase(),
      orElse: () => AppConstants.zodiacSigns[0],
    );
    final color = Color(signData['color'] as int);
    final horoData = context.read<HoroscopeProvider>().getHoroscope(
      signData['name'] as String,
      _selectedPeriod,
    );

    return Scaffold(
      body: Stack(
        children: [
          const StarBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 220,
                  backgroundColor: Colors.transparent,
                  leading: GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textPrimary),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [color.withValues(alpha: 0.25), Colors.transparent],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 36),
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  color.withValues(alpha: 0.8),
                                  color.withValues(alpha: 0.2),
                                ],
                              ),
                              border: Border.all(color: color, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                signData['symbol'] as String,
                                style: const TextStyle(
                                  fontSize: 34,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ShaderMask(
                            shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                            child: Text(
                              signData['name'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            signData['dateRange'] as String,
                            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Pill(label: '${signData['element']} Element', color: color),
                              const SizedBox(width: 8),
                              _Pill(label: 'Ruling Sign', color: color),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Period Selector ──────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['Today', 'This Week', 'This Month'].map((p) {
                        final isSel = _selectedPeriod == p;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(p),
                            selected: isSel,
                            selectedColor: AppTheme.royalPurple,
                            backgroundColor: AppTheme.cardBgLight,
                            labelStyle: GoogleFonts.outfit(
                              color: isSel ? Colors.white : AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                            ),
                            side: BorderSide(
                              color: isSel ? AppTheme.starGold : Colors.transparent,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedPeriod = p);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Astrological Reading ─────────────────────
                      _SectionCard(
                        title: '$_selectedPeriod\'s Celestial Reading',
                        icon: Icons.auto_awesome_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedPeriod == 'Today' && _geminiToday != null) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.royalPurple.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bolt_rounded, size: 13, color: AppTheme.starGold),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Daily Gemini 2.5 Flash Forecast',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.starGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _geminiToday!['overview'] ?? '',
                                style: GoogleFonts.outfit(fontSize: 14.5, color: AppTheme.textSecondary, height: 1.7),
                              ),
                              if (_geminiToday!['careerFinance'] != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  '💼 Career & Wealth: ${_geminiToday!['careerFinance']}',
                                  style: GoogleFonts.outfit(fontSize: 13.5, color: AppTheme.textSecondary, height: 1.6),
                                ),
                              ],
                              if (_geminiToday!['loveRelationship'] != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '❤️ Love & Relationships: ${_geminiToday!['loveRelationship']}',
                                  style: GoogleFonts.outfit(fontSize: 13.5, color: AppTheme.textSecondary, height: 1.6),
                                ),
                              ],
                            ] else ...[
                              Text(
                                horoData['reading'] as String? ?? horoData['today'] as String,
                                style: GoogleFonts.outfit(fontSize: 14.5, color: AppTheme.textSecondary, height: 1.7),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Energetic Vitality Sliders ───────────────
                      _SectionCard(
                        title: 'Energetic Vitality Meter',
                        icon: Icons.insights_rounded,
                        child: Column(
                          children: [
                            _MeterRow(label: 'Love & Resonance', score: horoData['love'] as int, color: const Color(0xFFFF6B9D), icon: Icons.favorite_rounded),
                            _MeterRow(label: 'Career & Ambition', score: horoData['career'] as int, color: const Color(0xFF00B4D8), icon: Icons.work_rounded),
                            _MeterRow(label: 'Physical Vitality', score: horoData['health'] as int, color: const Color(0xFF2ED573), icon: Icons.fitness_center_rounded),
                            _MeterRow(label: 'Financial Inflow', score: horoData['finance'] as int, color: AppTheme.starGold, icon: Icons.account_balance_wallet_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Auspicious Alignments ────────────────────
                      _SectionCard(
                        title: 'Auspicious Alignments',
                        icon: Icons.explore_rounded,
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            _AffinityTile(
                              label: 'Lucky Number',
                              value: (_selectedPeriod == 'Today' && _geminiToday?['luckyNumber'] != null)
                                  ? _geminiToday!['luckyNumber'].toString()
                                  : horoData['lucky_number'] as String,
                              icon: Icons.tag_rounded,
                            ),
                            _AffinityTile(
                              label: 'Lucky Shade',
                              value: (_selectedPeriod == 'Today' && _geminiToday?['luckyColor'] != null)
                                  ? _geminiToday!['luckyColor'].toString()
                                  : horoData['lucky_color'] as String,
                              icon: Icons.palette_outlined,
                            ),
                            _AffinityTile(
                              label: 'Auspicious Timing',
                              value: (_selectedPeriod == 'Today' && _geminiToday?['luckyTime'] != null)
                                  ? _geminiToday!['luckyTime'].toString()
                                  : (horoData['lucky_direction'] as String),
                              icon: Icons.compass_calibration_outlined,
                            ),
                            _AffinityTile(
                              label: 'Harmonic Gemstone',
                              value: (_selectedPeriod == 'Today' && _geminiToday?['luckyGemstone'] != null)
                                  ? _geminiToday!['luckyGemstone'].toString()
                                  : horoData['lucky_gemstone'] as String,
                              icon: Icons.diamond_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Vedic Affirmation & Mantra ───────────────
                      _SectionCard(
                        title: 'Vedic Affirmation',
                        icon: Icons.self_improvement_rounded,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.royalPurple.withValues(alpha: 0.2),
                                AppTheme.deepPurple.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                horoData['mantra'] as String? ?? 'Om Shanti Shanti Shanti',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.starGold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Recite 108 times at dawn or before retiring for optimal planetary resonance.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.starGold),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MeterRow extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final IconData icon;

  const _MeterRow({
    required this.label,
    required this.score,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: LinearPercentIndicator(
              lineHeight: 8,
              percent: score / 100,
              backgroundColor: AppTheme.cardBgLight,
              progressColor: color,
              barRadius: const Radius.circular(6),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
          Text(
            '$score%',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _AffinityTile extends StatelessWidget {
  final String label, value;
  final IconData icon;

  const _AffinityTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.cardBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.starGold),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textMuted)),
                Text(
                  value,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
