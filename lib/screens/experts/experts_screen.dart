import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/star_background.dart';

class ExpertsScreen extends StatefulWidget {
  final bool isTab;
  const ExpertsScreen({super.key, this.isTab = false});

  @override
  State<ExpertsScreen> createState() => _ExpertsScreenState();
}

class _ExpertsScreenState extends State<ExpertsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Online', 'Vedic', 'Tarot', 'Numerology', 'Vastu', 'Palm'];

  final List<Map<String, dynamic>> _experts = const [
    {
      'id': '1',
      'name': 'Pt. Rajesh Sharma',
      'icon': Icons.psychology_outlined,
      'spec': 'Vedic Astrology',
      'rating': 4.9,
      'reviews': 2847,
      'price': 15,
      'exp': '15 yrs',
      'online': true,
      'languages': ['Hindi', 'English'],
      'bio': 'Specialist in Vedic Jyotish, Kundli verification, and planetary remedies. Over 15 years guiding personal and professional transitions.',
      'consultations': '12,000+',
    },
    {
      'id': '2',
      'name': 'Meera Devi Joshi',
      'icon': Icons.auto_stories_outlined,
      'spec': 'Tarot & Numerology',
      'rating': 4.8,
      'reviews': 1923,
      'price': 10,
      'exp': '10 yrs',
      'online': true,
      'languages': ['Hindi', 'Gujarati'],
      'bio': 'Empathetic counselor focusing on Tarot spreads and Pythagorean numerology to identify auspicious lifepath cycles.',
      'consultations': '8,500+',
    },
    {
      'id': '3',
      'name': 'Acharya Suresh Kumar',
      'icon': Icons.pan_tool_alt_outlined,
      'spec': 'Palm Reading & KP',
      'rating': 4.7,
      'reviews': 3102,
      'price': 20,
      'exp': '20 yrs',
      'online': false,
      'languages': ['Hindi', 'Telugu'],
      'bio': 'Master palmist and Krishnamurti Padhdhati (KP) astrologer specializing in acute event timing.',
      'consultations': '15,000+',
    },
    {
      'id': '4',
      'name': 'Dr. Priya Nair',
      'icon': Icons.villa_outlined,
      'spec': 'Vastu Shastra',
      'rating': 4.9,
      'reviews': 1456,
      'price': 25,
      'exp': '12 yrs',
      'online': true,
      'languages': ['English', 'Malayalam'],
      'bio': 'Certified architectural Vastu consultant harmonizing commercial and residential energy orientations.',
      'consultations': '5,000+',
    },
    {
      'id': '5',
      'name': 'Pt. Arvind Tiwari',
      'icon': Icons.self_improvement_outlined,
      'spec': 'Lal Kitab & Nadi',
      'rating': 4.6,
      'reviews': 892,
      'price': 12,
      'exp': '8 yrs',
      'online': true,
      'languages': ['Hindi', 'Punjabi'],
      'bio': 'Lal Kitab practitioner specializing in straightforward domestic remedies and ancestral karma balance.',
      'consultations': '3,200+',
    },
  ];

  List<Map<String, dynamic>> get _filteredExperts {
    if (_selectedFilter == 'All') return _experts;
    if (_selectedFilter == 'Online') return _experts.where((e) => e['online'] as bool).toList();
    return _experts.where((e) => (e['spec'] as String).contains(_selectedFilter)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (!widget.isTab) const StarBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
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
                            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      const Icon(Icons.support_agent_rounded, color: AppTheme.starGold, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Verified Astrologers',
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

                // Filters
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final f = _filters[i];
                      final isSel = _selectedFilter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.royalPurple : AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel ? AppTheme.starGold : AppTheme.divider,
                            ),
                          ),
                          child: Text(
                            f,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                              color: isSel ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    itemCount: _filteredExperts.length,
                    itemBuilder: (context, i) {
                      final e = _filteredExperts[i];
                      return GestureDetector(
                        onTap: () => context.push('/experts/${e['id']}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassCard,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.royalPurple.withValues(alpha: 0.2),
                                      border: Border.all(color: AppTheme.royalPurple.withValues(alpha: 0.4)),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        e['icon'] as IconData,
                                        size: 26,
                                        color: AppTheme.starGold,
                                      ),
                                    ),
                                  ),
                                  if (e['online'] as bool)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.successGreen,
                                          shape: BoxShape.circle,
                                          border: Border.fromBorderSide(
                                            BorderSide(color: AppTheme.cardBg, width: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            e['name'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.outfit(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified,
                                          color: AppTheme.celestialTeal,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      e['spec'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppTheme.starGold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      (e['languages'] as List).join(', '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: AppTheme.starGold,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${e['rating']}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '(${e['reviews']})',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '• ${e['exp']}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${e['price']}/min',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => context.push('/experts/chat/${e['id']}'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.purpleGradient,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        e['online'] as bool ? 'Consult' : 'Schedule',
                                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
