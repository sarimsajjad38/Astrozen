import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/star_background.dart';

class ExpertProfileScreen extends StatelessWidget {
  final String expertId;
  const ExpertProfileScreen({super.key, required this.expertId});

  static const List<Map<String, dynamic>> _expertsData = [
    {
      'id': '1',
      'name': 'Pt. Rajesh Sharma',
      'icon': Icons.psychology_outlined,
      'spec': 'Vedic Astrology & Prashna',
      'rating': 4.9,
      'reviews': 2847,
      'price': 15,
      'exp': '15 yrs',
      'online': true,
      'languages': ['Hindi', 'English'],
      'bio': 'Senior astrologer holding Jyotish Acharya credentials from Varanasi. Specializing in career trajectory analysis, planetary dasha adjustments, and Vedic gemology.',
      'consultations': '12,000+',
      'expertise': ['Kundli Milan', 'Career Growth', 'Gemstone Therapy', 'Vedic Puja Guidance'],
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
      'bio': 'Internationally recognized Tarot reader and Master Numerologist helping individuals decode repetitive synchronicities and relationship paths.',
      'consultations': '8,500+',
      'expertise': ['Celtic Cross Spread', 'Lifepath Mapping', 'Relationship Alignment'],
    },
    {
      'id': '3',
      'name': 'Acharya Suresh Kumar',
      'icon': Icons.pan_tool_alt_outlined,
      'spec': 'Palm Reading & KP Astrology',
      'rating': 4.7,
      'reviews': 3102,
      'price': 20,
      'exp': '20 yrs',
      'online': false,
      'languages': ['Hindi', 'Telugu'],
      'bio': 'Pioneering researcher in sub-lord KP astrology and Hastarekha Shastra. Celebrated for high-precision temporal forecasts.',
      'consultations': '15,000+',
      'expertise': ['Palmar Dermatoglyphics', 'Sub-Lord KP System', 'Muhurat Calculations'],
    },
    {
      'id': '4',
      'name': 'Dr. Priya Nair',
      'icon': Icons.villa_outlined,
      'spec': 'Vastu Shastra Consultant',
      'rating': 4.9,
      'reviews': 1456,
      'price': 25,
      'exp': '12 yrs',
      'online': true,
      'languages': ['English', 'Malayalam'],
      'bio': 'Holder of doctorate in traditional Indian spatial energies. Consulted for over 500 commercial estates and urban habitats worldwide.',
      'consultations': '5,000+',
      'expertise': ['Structural Vastu', 'Color Geometry', 'Remedial Energy Anchors'],
    },
    {
      'id': '5',
      'name': 'Pt. Arvind Tiwari',
      'icon': Icons.self_improvement_outlined,
      'spec': 'Lal Kitab & Nadi Jyotish',
      'rating': 4.6,
      'reviews': 892,
      'price': 12,
      'exp': '8 yrs',
      'online': true,
      'languages': ['Hindi', 'Punjabi'],
      'bio': 'Dedicated to classical Lal Kitab principles that resolve recurring familial hindrances through accessible daily rituals.',
      'consultations': '3,200+',
      'expertise': ['Lal Kitab Remedies', 'Nadi Leaf Reading', 'Dosh Nivaran'],
    },
  ];

  void _showBookingSheet(BuildContext context, Map<String, dynamic> expert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(expert['icon'] as IconData, color: AppTheme.starGold, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Consult with ${expert['name']}',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Select preferred consultation channel. All calls are private and encrypted.',
              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/experts/chat/${expert['id']}');
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('Start Chat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.celestialTeal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/experts/call/${expert['id']}');
                    },
                    icon: const Icon(Icons.call_outlined, size: 16),
                    label: const Text('Audio Call'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expert = _expertsData.firstWhere(
      (e) => e['id'] == expertId,
      orElse: () => _expertsData[0],
    );

    final expertise = (expert['expertise'] as List?) ?? [];

    return Scaffold(
      body: Stack(
        children: [
          const StarBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  leading: GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/experts');
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
                  expandedHeight: 230,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.royalPurple.withValues(alpha: 0.3),
                              border: Border.all(
                                color: AppTheme.starGold,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                expert['icon'] as IconData,
                                size: 36,
                                color: AppTheme.starGold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                expert['name'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: AppTheme.celestialTeal,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expert['spec'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppTheme.starGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Performance Row
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassCard,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Metric(label: 'Rating', value: '${expert['rating']} ★'),
                            _Metric(label: 'Consults', value: expert['consultations'] as String),
                            _Metric(label: 'Experience', value: expert['exp'] as String),
                            _Metric(label: 'Rate', value: '₹${expert['price']}/min'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bio
                      Text(
                        'About Astrologer',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassCard,
                        child: Text(
                          expert['bio'] as String,
                          style: GoogleFonts.outfit(fontSize: 13.5, color: AppTheme.textSecondary, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Expertise Chips
                      Text(
                        'Core Disciplines',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: expertise.map((item) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBgLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.royalPurple.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            item.toString(),
                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textPrimary),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 36),

                      // CTA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showBookingSheet(context, expert),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Consult Now (₹${expert['price']}/min)',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
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

class _Metric extends StatelessWidget {
  final String label, value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.starGold)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }
}
