import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/star_background.dart';

import 'payment_checkout_modal.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  int _selectedPlan = 0; // 0=trial, 1=monthly, 2=annual

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _subscribe() {
    final plans = [
      AppConstants.trialPlan,
      AppConstants.monthlyPlan,
      AppConstants.annualPlan,
    ];
    PaymentCheckoutModal.show(context, plans[_selectedPlan], _selectedPlan);
  }

  @override
  Widget build(BuildContext context) {
    final plans = [
      AppConstants.trialPlan,
      AppConstants.monthlyPlan,
      AppConstants.annualPlan,
    ];

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
                  expandedHeight: 160,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 38,
                          color: AppTheme.starGold,
                        ),
                        const SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                          child: Text(
                            'AstroZen Premium Membership',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Vedic chart computations, palmistry & remedies',
                          style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ...List.generate(plans.length, (i) {
                        final p = plans[i];
                        final isSel = _selectedPlan == i;
                        final isTrial = i == 0;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPlan = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppTheme.cardBg
                                  : AppTheme.cardBg.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSel ? AppTheme.starGold : AppTheme.divider,
                                width: isSel ? 1.8 : 1,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.starGold.withValues(alpha: 0.12),
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (isTrial)
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 4),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.starGold.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'INTRODUCTORY ACCESS',
                                              style: GoogleFonts.outfit(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.starGold,
                                              ),
                                            ),
                                          ),
                                        Text(
                                          p['name'] as String,
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          p['duration'] as String,
                                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${p['price']}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: isSel ? AppTheme.starGold : AppTheme.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          i == 0 ? 'one-time' : 'per period',
                                          style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(color: AppTheme.divider, height: 1),
                                const SizedBox(height: 12),
                                ...(p['features'] as List).map((f) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: AppTheme.starGold, size: 16),
                                      const SizedBox(width: 10),
                                      Text(
                                        f.toString(),
                                        style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _subscribe,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Activate ${_selectedPlan == 0 ? "7-Day Trial for ₹11" : "Membership"}',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Encrypted via 256-bit SSL · Cancel anytime in Settings',
                          style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ),
                      const SizedBox(height: 30),
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
