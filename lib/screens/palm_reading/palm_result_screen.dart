import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai_astrology_service.dart';
import '../../widgets/common/star_background.dart';

class PalmResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const PalmResultScreen({super.key, required this.data});

  @override
  State<PalmResultScreen> createState() => _PalmResultScreenState();
}

class _PalmResultScreenState extends State<PalmResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RoyalAstrologyReading reading;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    reading = RoyalAstrologyReading.fromMap(widget.data);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareReading() {
    Share.share(
      '🌟 Royal Vedic & Palm Reading for ${reading.name}:\n'
      '• Rashi: ${reading.rashi}\n'
      '• Lagna: ${reading.lagna}\n'
      '• Nakshatra: ${reading.nakshatra}\n'
      '• Lucky Gemstone: ${reading.luckyGemstone}\n\n'
      'Read full forecast on AstroZen AI App!',
      subject: 'AstroZen Royal Astrology Report',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const StarBackground(),
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
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
                          child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reading.name,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Royal Vedic & Palm Reading',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.starGold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: AppTheme.starGold),
                        onPressed: _shareReading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Step 1 vs Step 2 Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.royalPurple.withValues(alpha: 0.3)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppTheme.purpleGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.textMuted,
                      tabs: const [
                        Tab(text: 'Step 1: The Reading (Text)'),
                        Tab(text: 'Step 2: Royal Infographic (9:16)'),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _Step1TextReadingView(reading: reading),
                      _Step2RoyalInfographicView(reading: reading, onShare: _shareReading),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1: The Reading (Text in Friendly Hinglish)
// ─────────────────────────────────────────────────────────────────────────────
class _Step1TextReadingView extends StatelessWidget {
  final RoyalAstrologyReading reading;
  const _Step1TextReadingView({required this.reading});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Rashi, Lagna, Nakshatra Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF35125E), Color(0xFF131842)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AstrologyPill('Rashi (Moon)', reading.rashi, Icons.nightlight_round),
              _AstrologyPill('Lagna (Ascendant)', reading.lagna, Icons.wb_sunny_rounded),
              _AstrologyPill('Nakshatra', reading.nakshatra, Icons.stars_rounded),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Friendly Hinglish Narrative Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.glassCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppTheme.starGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Vedic Astrologer & Palmist Synthesis',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.starGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                reading.hinglishReading,
                style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, height: 1.65),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Personality: 3 Key Strengths
        _SectionContainer(
          title: 'Personality: 3 Key Strengths',
          icon: Icons.psychology_outlined,
          children: reading.personalityStrengths.map((str) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_rounded, color: AppTheme.successGreen, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    str,
                    style: GoogleFonts.outfit(fontSize: 13.5, color: AppTheme.textPrimary, height: 1.4),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 18),

        // Palm Reading Details
        _SectionContainer(
          title: 'Palm Reading: Major Lines & Mounts',
          icon: Icons.pan_tool_outlined,
          children: reading.palmLineInsights.entries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardBgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.starGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.value,
                  style: GoogleFonts.outfit(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.4),
                ),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 18),

        // Career Guidance
        _SectionContainer(
          title: 'Career & Golden Growth Years',
          icon: Icons.work_outline_rounded,
          children: [
            _InfoRow('Best Fields', reading.careerSummary),
            const SizedBox(height: 6),
            _InfoRow('Strongest Growth Phase', reading.careerGrowthYears),
          ],
        ),
        const SizedBox(height: 18),

        // Love & Marriage
        _SectionContainer(
          title: 'Love Life & Marriage Outlook',
          icon: Icons.favorite_border_rounded,
          children: [
            _InfoRow('Nature in Love', reading.loveNature),
            const SizedBox(height: 6),
            _InfoRow('Ideal Partner Profile', reading.idealPartner),
            const SizedBox(height: 6),
            _InfoRow('Marriage Age Window', reading.marriageAgeRange),
            const SizedBox(height: 6),
            _InfoRow('Married Life Harmony', reading.marriageLifeOutlook),
          ],
        ),
        const SizedBox(height: 18),

        // Money & Wealth
        _SectionContainer(
          title: 'Money & Wealth Accumulation',
          icon: Icons.account_balance_wallet_outlined,
          children: [
            _InfoRow('Wealth Growth', reading.wealthBuildingOutlook),
          ],
        ),
        const SizedBox(height: 18),

        // Lucky Badges Grid
        _SectionContainer(
          title: 'Lucky Celestial Elements',
          icon: Icons.stars_outlined,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _BadgeBox('Lucky Number', reading.luckyNumber, Icons.tag_rounded),
                _BadgeBox('Lucky Colour', reading.luckyColour, Icons.palette_outlined),
                _BadgeBox('Lucky Day', reading.luckyDay, Icons.calendar_today_rounded),
                _BadgeBox('Lucky Gemstone', reading.luckyGemstone, Icons.diamond_outlined),
              ],
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2: The Visual Chart (Royal 9:16 Vertical Infographic)
// ─────────────────────────────────────────────────────────────────────────────
class _Step2RoyalInfographicView extends StatelessWidget {
  final RoyalAstrologyReading reading;
  final VoidCallback onShare;

  const _Step2RoyalInfographicView({
    required this.reading,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // 9:16 Aspect Ratio Royal Poster
          AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Color(0xFF280B52),
                    Color(0xFF0F092E),
                    Color(0xFF050714),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.starGold.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.royalPurple.withValues(alpha: 0.6),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Subtle background stars & ornamental corner accents
                  Positioned(
                    top: 12, left: 12,
                    child: Icon(Icons.star, size: 10, color: AppTheme.starGold.withValues(alpha: 0.4)),
                  ),
                  Positioned(
                    top: 12, right: 12,
                    child: Icon(Icons.star, size: 10, color: AppTheme.starGold.withValues(alpha: 0.4)),
                  ),
                  Positioned(
                    bottom: 12, left: 12,
                    child: Icon(Icons.star, size: 10, color: AppTheme.starGold.withValues(alpha: 0.4)),
                  ),
                  Positioned(
                    bottom: 12, right: 12,
                    child: Icon(Icons.star, size: 10, color: AppTheme.starGold.withValues(alpha: 0.4)),
                  ),

                  // Content Layout inside 9:16
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ── Top: Royal Header ────────────────────────
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(height: 1, width: 24, color: AppTheme.starGold),
                                const SizedBox(width: 6),
                                const Icon(Icons.auto_awesome_rounded, color: AppTheme.starGold, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'ROYAL ASTROLOGY REPORT',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    letterSpacing: 3,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.starGold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(height: 1, width: 24, color: AppTheme.starGold),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ShaderMask(
                              shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                              child: Text(
                                reading.name.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _MicroBadge(reading.rashi),
                                const SizedBox(width: 4),
                                _MicroBadge(reading.lagna),
                                const SizedBox(width: 4),
                                _MicroBadge(reading.nakshatra),
                              ],
                            ),
                          ],
                        ),

                        // ── Middle: Kundli Diamond + Palm Line Illustration
                        Row(
                          children: [
                            // Traditional North Indian Kundli (Diamond Style in Gold)
                            Expanded(
                              flex: 5,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.4)),
                                  ),
                                  child: CustomPaint(
                                    painter: _MiniGoldKundliPainter(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Illustrated Palm with highlighted & labelled lines
                            Expanded(
                              flex: 5,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.roseGold.withValues(alpha: 0.4)),
                                  ),
                                  child: CustomPaint(
                                    painter: _MiniPalmLinePainter(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ── 4 Sections: Career 💼, Love ❤️, Marriage 💍, Money 💰
                        Column(
                          children: [
                            _InfographicTopicCard(
                              icon: '💼',
                              title: 'Career',
                              text: reading.careerSummary,
                              accentColor: const Color(0xFF00B4D8),
                            ),
                            const SizedBox(height: 5),
                            _InfographicTopicCard(
                              icon: '❤️',
                              title: 'Love',
                              text: reading.loveNature,
                              accentColor: const Color(0xFFFF6B9D),
                            ),
                            const SizedBox(height: 5),
                            _InfographicTopicCard(
                              icon: '💍',
                              title: 'Marriage',
                              text: '${reading.marriageAgeRange} • ${reading.marriageLifeOutlook}',
                              accentColor: const Color(0xFFFFD700),
                            ),
                            const SizedBox(height: 5),
                            _InfographicTopicCard(
                              icon: '💰',
                              title: 'Money',
                              text: reading.wealthBuildingOutlook,
                              accentColor: const Color(0xFF2ED573),
                            ),
                          ],
                        ),

                        // ── Bottom: Small Lucky Badges ───────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _MiniBadge('Number', reading.luckyNumber),
                              _MiniBadge('Colour', reading.luckyColour),
                              _MiniBadge('Day', reading.luckyDay.split(' ')[0]),
                              _MiniBadge('Stone', reading.luckyGemstone.split(' ')[0]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(
                'Share Royal Infographic Poster',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.royalPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painters for Traditional North Indian Kundli & Palm Lines
// ─────────────────────────────────────────────────────────────────────────────
class _MiniGoldKundliPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = AppTheme.starGold.withValues(alpha: 0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
    canvas.drawLine(Offset.zero, Offset(w, h), paint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), paint);

    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w / 2, h)
      ..lineTo(0, h / 2)
      ..close();
    canvas.drawPath(path, paint);

    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: 'Vedic Kundli',
      style: GoogleFonts.outfit(fontSize: 9, color: AppTheme.starGold, fontWeight: FontWeight.bold),
    );
    tp.layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, h / 4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniPalmLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Palm outline
    final palmPaint = Paint()
      ..color = AppTheme.roseGold.withValues(alpha: 0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final palmRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.7, h * 0.75),
      const Radius.circular(16),
    );
    canvas.drawRRect(palmRect, palmPaint);

    // Heart line (Pink)
    final heartPaint = Paint()
      ..color = const Color(0xFFFF6B9D)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final heartPath = Path()
      ..moveTo(w * 0.25, h * 0.35)
      ..quadraticBezierTo(w * 0.5, h * 0.42, w * 0.75, h * 0.32);
    canvas.drawPath(heartPath, heartPaint);

    // Head line (Blue)
    final headPaint = Paint()
      ..color = const Color(0xFF00B4D8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final headPath = Path()
      ..moveTo(w * 0.25, h * 0.45)
      ..quadraticBezierTo(w * 0.55, h * 0.50, w * 0.78, h * 0.58);
    canvas.drawPath(headPath, headPaint);

    // Life line (Green)
    final lifePaint = Paint()
      ..color = const Color(0xFF2ED573)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final lifePath = Path()
      ..moveTo(w * 0.28, h * 0.44)
      ..quadraticBezierTo(w * 0.38, h * 0.65, w * 0.45, h * 0.85);
    canvas.drawPath(lifePath, lifePaint);

    // Fate line (Gold)
    final fatePaint = Paint()
      ..color = AppTheme.starGold
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.52, h * 0.82), Offset(w * 0.52, h * 0.38), fatePaint);

    // Text label
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: 'Palm Lines',
      style: GoogleFonts.outfit(fontSize: 9, color: AppTheme.roseGold, fontWeight: FontWeight.bold),
    );
    tp.layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, 4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _SectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionContainer({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _AstrologyPill extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _AstrologyPill(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.starGold),
        const SizedBox(height: 3),
        Text(value, style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
        children: [
          TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _BadgeBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _BadgeBox(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.cardBgLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.starGold),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: GoogleFonts.outfit(fontSize: 9.5, color: AppTheme.textMuted)),
                Text(
                  value,
                  style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
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

class _MicroBadge extends StatelessWidget {
  final String text;
  const _MicroBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.royalPurple.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.starGold),
      ),
    );
  }
}

class _InfographicTopicCard extends StatelessWidget {
  final String icon;
  final String title;
  final String text;
  final Color accentColor;

  const _InfographicTopicCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  text,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
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

class _MiniBadge extends StatelessWidget {
  final String label, value;
  const _MiniBadge(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.starGold)),
        Text(label, style: GoogleFonts.outfit(fontSize: 8, color: AppTheme.textMuted)),
      ],
    );
  }
}
