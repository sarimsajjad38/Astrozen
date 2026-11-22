import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/star_background.dart';

class KundliResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const KundliResultScreen({super.key, required this.data});

  @override
  State<KundliResultScreen> createState() => _KundliResultScreenState();
}

class _KundliResultScreenState extends State<KundliResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['Chart', 'Planets', 'Yogas', 'Predictions', 'Remedies'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Scaffold(
      body: Stack(
        children: [
          const StarBackground(),
          SafeArea(
            child: Column(
              children: [
                // ── Top Bar ──────────────────────────────────────
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
                              d['name'] as String? ?? 'Vedic Chart',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Born: ${d['dob']} · ${d['place']}',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: AppTheme.starGold),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // ── Overview Pills ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _Pill('Lagna', d['lagna'] as String? ?? '—', AppTheme.royalPurple),
                        const SizedBox(width: 8),
                        _Pill('Moon Sign', d['moonSign'] as String? ?? '—', AppTheme.celestialTeal),
                        const SizedBox(width: 8),
                        _Pill('Nakshatra', d['nakshatra'] as String? ?? '—', AppTheme.roseGold),
                        const SizedBox(width: 8),
                        _Pill('Dasha', d['currentDasha'] as String? ?? '—', AppTheme.successGreen),
                      ],
                    ),
                  ),
                ),

                // ── Tabs ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(color: AppTheme.starGold, width: 2),
                    ),
                    labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
                    unselectedLabelStyle: GoogleFonts.outfit(fontSize: 14),
                    labelColor: AppTheme.starGold,
                    unselectedLabelColor: AppTheme.textMuted,
                    dividerColor: AppTheme.divider,
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),

                // ── Tab Views ────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ChartView(data: d),
                      _PlanetsView(data: d),
                      _YogasView(data: d),
                      _PredictionsView(data: d),
                      _RemediesView(data: d),
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

class _ChartView extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ChartView({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.goldBorderCard,
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: _NorthIndianChartPainter(data),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatBadge('Ascendant', data['lagna'] as String? ?? '—', Icons.wb_sunny_rounded),
              _StatBadge('Moon Sign', data['moonSign'] as String? ?? '—', Icons.nightlight_round),
              _StatBadge('Sun Sign', data['sunSign'] as String? ?? '—', Icons.flare_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _NorthIndianChartPainter extends CustomPainter {
  final Map<String, dynamic> data;
  _NorthIndianChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final borderPaint = Paint()
      ..color = AppTheme.starGold.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final linePaint = Paint()
      ..color = AppTheme.starGold.withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), borderPaint);
    canvas.drawLine(Offset.zero, Offset(w, h), linePaint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), linePaint);

    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w / 2, h)
      ..lineTo(0, h / 2)
      ..close();
    canvas.drawPath(path, linePaint);

    // Label Center House (House 1 - Lagna)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: 'Lagna: ${data['lagna'] ?? ""}',
      style: GoogleFonts.outfit(color: AppTheme.starGold, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((w - textPainter.width) / 2, h / 4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlanetsView extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PlanetsView({required this.data});

  @override
  Widget build(BuildContext context) {
    final planets = (data['planetPositions'] as List?) ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: planets.length,
      itemBuilder: (context, i) {
        final p = planets[i] as Map;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.glassCard,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.royalPurple.withValues(alpha: 0.25),
                ),
                child: Center(
                  child: Text(
                    p['planet'].toString().substring(0, 2),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.starGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['planet'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${p['sign']} · House ${p['house']}',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    p['degree'] as String,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  Text(
                    p['status'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: p['status'] == 'Exalted' || p['status'] == 'Own Sign'
                          ? AppTheme.successGreen
                          : AppTheme.starGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _YogasView extends StatelessWidget {
  final Map<String, dynamic> data;
  const _YogasView({required this.data});

  @override
  Widget build(BuildContext context) {
    final yogas = (data['yogas'] as List?) ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: yogas.length,
      itemBuilder: (context, i) {
        final y = yogas[i] as Map;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    y['name'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.starGold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      y['strength'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                y['description'] as String,
                style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PredictionsView extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PredictionsView({required this.data});

  @override
  Widget build(BuildContext context) {
    final preds = (data['predictions'] as Map?) ?? {};
    return ListView(
      padding: const EdgeInsets.all(20),
      children: preds.entries.map((e) {
        final category = e.key.toString();
        final text = e.value.toString();
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.starGold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: GoogleFonts.outfit(fontSize: 13.5, color: AppTheme.textSecondary, height: 1.6),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RemediesView extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RemediesView({required this.data});

  @override
  Widget build(BuildContext context) {
    final remedies = (data['remedies'] as List?) ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: remedies.length,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.glassCard,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppTheme.starGold, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  remedies[i].toString(),
                  style: GoogleFonts.outfit(fontSize: 13.5, color: AppTheme.textPrimary, height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Pill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted)),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 12, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatBadge(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.starGold),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }
}
