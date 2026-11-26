import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/star_background.dart';

class VastuScreen extends StatefulWidget {
  const VastuScreen({super.key});

  @override
  State<VastuScreen> createState() => _VastuScreenState();
}

class _VastuScreenState extends State<VastuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _mainDoorDir = 'North';
  String? _kitchenDir = 'SouthEast';
  String? _masterBedDir = 'SouthWest';
  bool _analysisReady = true;
  int _vastuScore = 85;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _analyzeVastu() {
    int score = 50;
    if (_mainDoorDir == 'North' || _mainDoorDir == 'East' || _mainDoorDir == 'NorthEast') {
      score += 20;
    }
    if (_kitchenDir == 'SouthEast') {
      score += 15;
    }
    if (_masterBedDir == 'South' || _masterBedDir == 'SouthWest') {
      score += 15;
    }
    setState(() {
      _vastuScore = score.clamp(0, 100);
      _analysisReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dirs = AppConstants.vastuDirections;
    return Scaffold(
      body: Stack(
        children: [
          const StarBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
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
                      const Icon(Icons.explore_outlined, color: AppTheme.starGold, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Vastu Shastra Compass',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.starGold,
                  labelColor: AppTheme.starGold,
                  unselectedLabelColor: AppTheme.textMuted,
                  tabs: const [
                    Tab(text: 'Home Assessment'),
                    Tab(text: 'Direction Reference'),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Assessment
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DirectionSelector(
                              label: 'Main Entrance Facing',
                              icon: Icons.door_front_door_outlined,
                              selected: _mainDoorDir,
                              onSelect: (val) => setState(() => _mainDoorDir = val),
                            ),
                            const SizedBox(height: 18),
                            _DirectionSelector(
                              label: 'Kitchen Quadrant',
                              icon: Icons.soup_kitchen_outlined,
                              selected: _kitchenDir,
                              onSelect: (val) => setState(() => _kitchenDir = val),
                            ),
                            const SizedBox(height: 18),
                            _DirectionSelector(
                              label: 'Master Bedroom Location',
                              icon: Icons.bed_outlined,
                              selected: _masterBedDir,
                              onSelect: (val) => setState(() => _masterBedDir = val),
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _analyzeVastu,
                                child: const Text('Calculate Spatial Harmony Score'),
                              ),
                            ),
                            const SizedBox(height: 24),

                            if (_analysisReady)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.4)),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Vastu Harmony Index',
                                      style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$_vastuScore / 100',
                                      style: GoogleFonts.outfit(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.starGold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _vastuScore >= 75
                                          ? 'Highly auspicious orientation fostering stability and vitality.'
                                          : 'Moderate spatial alignment. Placement adjustments can enhance tranquility.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textPrimary, height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Reference
                      ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: dirs.length,
                        itemBuilder: (context, i) {
                          final d = dirs[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: AppTheme.glassCard,
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.royalPurple.withValues(alpha: 0.25),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.explore_outlined, color: AppTheme.starGold, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d['dir'] as String,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Ruler: ${d['ruler']} · Element: ${d['element']}',
                                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ideal for: ${d['good']}',
                                        style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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

class _DirectionSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _DirectionSelector({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelect,
  });

  static const _directions = [
    'North', 'NorthEast', 'East', 'SouthEast',
    'South', 'SouthWest', 'West', 'NorthWest',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.starGold),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _directions.map((d) {
            final isSel = selected == d;
            return ChoiceChip(
              label: Text(d),
              selected: isSel,
              selectedColor: AppTheme.royalPurple,
              backgroundColor: AppTheme.cardBgLight,
              labelStyle: GoogleFonts.outfit(
                color: isSel ? Colors.white : AppTheme.textMuted,
                fontSize: 12,
              ),
              side: BorderSide(color: isSel ? AppTheme.starGold : Colors.transparent),
              onSelected: (val) {
                if (val) onSelect(d);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
