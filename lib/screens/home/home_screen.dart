import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/common/star_background.dart';
import '../horoscope/horoscope_screen.dart';
import '../kundli/kundli_screen.dart';
import '../experts/experts_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  late AnimationController _pulseController;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
      label: 'Horoscope',
    ),
    _NavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Kundli',
    ),
    _NavItem(
      icon: Icons.support_agent_outlined,
      activeIcon: Icons.support_agent_rounded,
      label: 'Experts',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: [
          Stack(
            children: [
              const StarBackground(),
              _HomeTab(
                pulseController: _pulseController,
                onNavigateToTab: (index) => setState(() => _currentTab = index),
              ),
            ],
          ),
          const HoroscopeScreen(isTab: true),
          const KundliScreen(isTab: true),
          const ExpertsScreen(isTab: true),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: const Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final isSelected = _currentTab == i;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _currentTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.royalPurple.withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? _navItems[i].activeIcon
                            : _navItems[i].icon,
                        color: isSelected
                            ? AppTheme.starGold
                            : AppTheme.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _navItems[i].label,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isSelected
                              ? AppTheme.starGold
                              : AppTheme.textMuted,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Home Tab Content ───────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final AnimationController pulseController;
  final ValueChanged<int> onNavigateToTab;

  const _HomeTab({
    required this.pulseController,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sub = context.watch<SubscriptionProvider>();
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';
    final IconData greetIcon = hour < 12
        ? Icons.wb_twilight_rounded
        : hour < 17
        ? Icons.wb_sunny_rounded
        : Icons.nightlight_round;

    return CustomScrollView(
      slivers: [
        // ── App Bar ─────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(greetIcon, size: 14, color: AppTheme.starGold),
                          const SizedBox(width: 6),
                          Text(
                            greeting,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        auth.userName ?? 'Cosmic Seeker',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.go('/subscribe'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.starGold.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            sub.isSubscribed
                                ? Icons.verified_rounded
                                : Icons.star_rounded,
                            size: 15,
                            color: AppTheme.deepSpace,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sub.isSubscribed ? 'Premium' : 'Trial ₹11',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.deepSpace,
                            ),
                          ),
                        ],
                      ),
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
              // ── Today's Cosmic Overview ──────────────────────────
              _SectionTitle(
                title: "Today's Cosmic Energy",
                icon: Icons.blur_on_rounded,
              ),
              const SizedBox(height: 12),
              _CosmicOverviewCard(
                pulseController: pulseController,
                onViewHoroscope: () => onNavigateToTab(1),
              ),
              const SizedBox(height: 28),

              // ── Feature Grid ─────────────────────────────────────
              _SectionTitle(
                title: 'Astrological Services',
                icon: Icons.grid_view_rounded,
              ),
              const SizedBox(height: 12),
              _FeatureGrid(onNavigateToTab: onNavigateToTab),
              const SizedBox(height: 28),

              // ── Zodiac Scroll ─────────────────────────────────────
              _SectionTitle(title: 'Zodiac Signs', icon: Icons.stars_rounded),
              const SizedBox(height: 12),
              _ZodiacScroll(),
              const SizedBox(height: 28),

              // ── Top Experts Preview ───────────────────────────────
              _SectionTitle(
                title: 'Verified Astrologers',
                icon: Icons.support_agent_rounded,
              ),
              const SizedBox(height: 12),
              _ExpertPreview(onViewAll: () => onNavigateToTab(3)),
              const SizedBox(height: 28),

              // ── Trial CTA ─────────────────────────────────────────
              _TrialBanner(),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: AppTheme.starGold),
      const SizedBox(width: 8),
      Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    ],
  );
}

class _CosmicOverviewCard extends StatelessWidget {
  final AnimationController pulseController;
  final VoidCallback onViewHoroscope;

  const _CosmicOverviewCard({
    required this.pulseController,
    required this.onViewHoroscope,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final signs = AppConstants.zodiacSigns;
    final month = now.month;
    final day = now.day;
    String todaySign = 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      todaySign = 'Sagittarius';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      todaySign = 'Capricorn';
    }

    final sign = signs.firstWhere(
      (s) => s['name'] == todaySign,
      orElse: () => signs[7],
    );
    final signColor = Color(sign['color'] as int);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [signColor.withValues(alpha: 0.2), AppTheme.cardBg],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: signColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) => Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: signColor.withValues(
                      alpha: 0.15 + 0.1 * pulseController.value,
                    ),
                    border: Border.all(
                      color: signColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: signColor.withValues(
                          alpha: 0.3 * pulseController.value,
                        ),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      sign['symbol'] as String,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
                      sign['name'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      sign['dateRange'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: signColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: signColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${sign['element']} Alignment',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: signColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _CosmicStat(
                label: 'Lucky #',
                value: '7',
                icon: Icons.tag_rounded,
              ),
              _CosmicStat(
                label: 'Color',
                value: 'Gold',
                icon: Icons.palette_outlined,
              ),
              _CosmicStat(
                label: 'Energy',
                value: 'High',
                icon: Icons.bolt_rounded,
              ),
              _CosmicStat(
                label: 'Moon',
                value: 'Waxing',
                icon: Icons.brightness_3_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onViewHoroscope,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBgLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Planetary configurations signal constructive clarity today. Mars stimulates purposeful resolve, while lunar alignments favor mindful communication and sustained focus...',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onViewHoroscope,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Explore full forecast',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.starGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.starGold,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CosmicStat extends StatelessWidget {
  final String label, value;
  final IconData icon;

  const _CosmicStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 18, color: AppTheme.starGold),
      const SizedBox(height: 4),
      Text(
        value,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      Text(
        label,
        style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted),
      ),
    ],
  );
}

class _FeatureGrid extends StatelessWidget {
  final ValueChanged<int> onNavigateToTab;

  const _FeatureGrid({required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final List<_FeatureItem> features = [
      _FeatureItem(
        icon: Icons.auto_awesome_rounded,
        name: 'Horoscope',
        subtitle: 'Daily celestial forecast',
        onTap: () => onNavigateToTab(1),
        color: AppTheme.royalPurple,
      ),
      _FeatureItem(
        icon: Icons.menu_book_rounded,
        name: 'Kundli',
        subtitle: 'Vedic birth chart',
        onTap: () => onNavigateToTab(2),
        color: AppTheme.celestialTeal,
      ),
      _FeatureItem(
        icon: Icons.favorite_border_rounded,
        name: 'Gun Milan',
        subtitle: '36-Guna matching',
        onTap: () => context.push('/kundli/matching'),
        color: const Color(0xFFFF6B9D),
      ),
      _FeatureItem(
        icon: Icons.pan_tool_outlined,
        name: 'Palm Reading',
        subtitle: 'AI line detection',
        onTap: () => context.go('/palm-reading'),
        color: AppTheme.roseGold,
      ),
      _FeatureItem(
        icon: Icons.explore_outlined,
        name: 'Vastu',
        subtitle: 'Spatial harmony',
        onTap: () => context.go('/vastu'),
        color: AppTheme.successGreen,
      ),
      _FeatureItem(
        icon: Icons.support_agent_rounded,
        name: 'Astrologers',
        subtitle: 'Live chat & call',
        onTap: () => onNavigateToTab(3),
        color: AppTheme.starGold,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: features.length,
      itemBuilder: (context, i) {
        final f = features[i];
        return GestureDetector(
          onTap: f.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: f.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: f.color.withValues(alpha: 0.25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: f.color.withValues(alpha: 0.2),
                  ),
                  child: Icon(f.icon, size: 22, color: f.color),
                ),
                const SizedBox(height: 8),
                Text(
                  f.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  f.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String name, subtitle;
  final VoidCallback onTap;
  final Color color;

  _FeatureItem({
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });
}

class _ZodiacScroll extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signs = AppConstants.zodiacSigns;
    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: signs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final s = signs[i];
          final color = Color(s['color'] as int);
          return GestureDetector(
            onTap: () =>
                context.go('/horoscope/${(s['name'] as String).toLowerCase()}'),
            child: Container(
              width: 82,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s['symbol'] as String,
                    style: TextStyle(
                      fontSize: 24,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s['name'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    s['element'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExpertPreview extends StatelessWidget {
  final VoidCallback onViewAll;

  const _ExpertPreview({required this.onViewAll});

  final List<Map<String, dynamic>> _experts = const [
    {
      'id': '1',
      'name': 'Pt. Rajesh Sharma',
      'spec': 'Vedic Astrology',
      'rating': 4.9,
      'price': '₹15/min',
      'icon': Icons.psychology_outlined,
      'online': true,
      'exp': '15 yrs',
    },
    {
      'id': '2',
      'name': 'Meera Devi Joshi',
      'spec': 'Tarot & Numerology',
      'rating': 4.8,
      'price': '₹10/min',
      'icon': Icons.auto_stories_outlined,
      'online': true,
      'exp': '10 yrs',
    },
    {
      'id': '3',
      'name': 'Acharya Suresh Kumar',
      'spec': 'Palm Reading & KP',
      'rating': 4.7,
      'price': '₹20/min',
      'icon': Icons.pan_tool_alt_outlined,
      'online': false,
      'exp': '20 yrs',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._experts.map(
          (e) => GestureDetector(
            onTap: () => context.go('/experts/${e['id']}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.glassCard,
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.royalPurple.withValues(alpha: 0.25),
                          border: Border.all(
                            color: AppTheme.royalPurple.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            e['icon'] as IconData,
                            size: 22,
                            color: AppTheme.starGold,
                          ),
                        ),
                      ),
                      if (e['online'] as bool)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
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
                        Text(
                          e['name'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          e['spec'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
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
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.purpleGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          e['online'] as bool ? 'Connect' : 'Schedule',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e['price'] as String,
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
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View all certified astrologers',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.starGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.starGold,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrialBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/subscribe'),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B1671), Color(0xFF0F1238)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.royalPurple.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: AppTheme.starGold,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AstroZen All-Access',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.starGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '7 days full access for just ₹11. Includes Kundli, Palmistry and remedies.',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Activate for ₹11',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepSpace,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.royalPurple.withValues(alpha: 0.3),
                border: Border.all(
                  color: AppTheme.starGold.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                size: 36,
                color: AppTheme.starGold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({required this.icon, required this.activeIcon, required this.label});
}
