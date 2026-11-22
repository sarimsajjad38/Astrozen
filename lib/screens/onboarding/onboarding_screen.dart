import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      icon: Icons.nightlight_round,
      title: 'Your Personal\nCosmic Compass',
      subtitle: 'Unlock precision Vedic horoscopes, planetary transit influences, and personalized astral forecasts tailored to your exact birth coordinates.',
      gradient: [Color(0xFF4A1C8F), Color(0xFF0D1035)],
      accent: AppTheme.royalPurple,
      features: ['Daily Horoscope', 'Planetary Forecast', 'Lucky Alignments'],
    ),
    _OnboardPage(
      icon: Icons.menu_book_rounded,
      title: 'AI-Powered\nKundli Analysis',
      subtitle: 'Instant birth chart computations including Lagna, Navamsa, Mahadasha timelines, and auspicious Yoga detections with Vedic remedies.',
      gradient: [Color(0xFF0077B6), Color(0xFF050714)],
      accent: AppTheme.celestialTeal,
      features: ['Lagna & Navamsa Chart', 'Yoga Detection', 'Dasha Timelines'],
    ),
    _OnboardPage(
      icon: Icons.pan_tool_outlined,
      title: 'Precision AI\nPalmistry Scanner',
      subtitle: 'Capture a photo of your palm. Our computer vision model maps the Life line, Heart line, Head line, and planetary mounts with detailed interpretations.',
      gradient: [Color(0xFF8B1A3A), Color(0xFF050714)],
      accent: AppTheme.roseGold,
      features: ['Biometric Analysis', '5 Major Palm Lines', 'Career & Vitality Insights'],
    ),
    _OnboardPage(
      icon: Icons.support_agent_rounded,
      title: 'Consult Real\nCertified Astrologers',
      subtitle: 'Connect securely with vetted Vedic scholars and intuitive consultants via private chat, audio, or video sessions for in-depth guidance.',
      gradient: [Color(0xFF1A5C3A), Color(0xFF050714)],
      accent: AppTheme.successGreen,
      features: ['Consultations from ₹10/min', 'Encrypted Sessions', 'Verified Vedic Masters'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: page.gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip Button ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.go('/auth'),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.outfit(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Pages ────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _floatAnim,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(0, _floatAnim.value),
                              child: child,
                            ),
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.accent.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: p.accent.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: p.accent.withValues(alpha: 0.35),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(p.icon, size: 64, color: AppTheme.starGold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          Text(
                            p.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 14),

                          Text(
                            p.subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),

                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: p.features.map((f) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: p.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: p.accent.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 13,
                                    color: AppTheme.starGold,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    f,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Indicator & Action ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: AppTheme.starGold,
                        dotColor: AppTheme.divider,
                        expansionFactor: 3,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.go('/auth');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.royalPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
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
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final String title, subtitle;
  final List<Color> gradient;
  final Color accent;
  final List<String> features;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accent,
    required this.features,
  });
}
