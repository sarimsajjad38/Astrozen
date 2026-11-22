import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: Stack(
          children: [
            // ── Star Field Background ──────────────────────────────
            ...List.generate(80, (i) {
              final rand = math.Random(i);
              return Positioned(
                left: rand.nextDouble() * MediaQuery.of(context).size.width,
                top: rand.nextDouble() * MediaQuery.of(context).size.height,
                child: AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) => Opacity(
                    opacity: (math.sin(_rotateController.value * 2 * math.pi + i) + 1) / 2 * 0.8 + 0.2,
                    child: Container(
                      width: rand.nextDouble() * 3 + 1,
                      height: rand.nextDouble() * 3 + 1,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }),

            // ── Rotating Celestial Ring ────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) => Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: child,
                ),
                child: Container(
                  width: 290,
                  height: 290,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.royalPurple.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.starGold.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                      ),
                      ...List.generate(12, (index) {
                        final angle = (index * 30) * math.pi / 180;
                        const radius = 138.0;
                        return Positioned(
                          left: 145 + radius * math.cos(angle) - 6,
                          top: 145 + radius * math.sin(angle) - 6,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index % 3 == 0
                                  ? AppTheme.starGold
                                  : AppTheme.royalPurple.withValues(alpha: 0.6),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.starGold.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // ── Center Brand Logo & Typography ─────────────────────
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [AppTheme.royalPurple, AppTheme.deepPurple],
                          ),
                          border: Border.all(
                            color: AppTheme.starGold.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.royalPurple.withValues(alpha: 0.6),
                              blurRadius: 36,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: AppTheme.starGold.withValues(alpha: 0.2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 46,
                            color: AppTheme.starGold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                        child: Text(
                          'ASTROZEN',
                          style: GoogleFonts.outfit(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'AI POWERED COSMIC INTELLIGENCE',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: 140,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            backgroundColor: AppTheme.cardBgLight,
                            valueColor: const AlwaysStoppedAnimation(AppTheme.starGold),
                            minHeight: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Footer ─────────────────────────────────────────────
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Vedic Ephemeris & Neural Astrology Engine',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
