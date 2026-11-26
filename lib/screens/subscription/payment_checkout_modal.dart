import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';

class PaymentCheckoutModal {
  static void show(BuildContext context, Map<String, dynamic> plan, int planIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CheckoutSheet(plan: plan, planIndex: planIndex),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  final Map<String, dynamic> plan;
  final int planIndex;
  const _CheckoutSheet({required this.plan, required this.planIndex});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  int _selectedMethod = 0; // 0=GPay, 1=PhonePe, 2=Paytm, 3=Card
  bool _isProcessing = false;
  bool _isSuccess = false;
  String _txnId = '';

  void _processPayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final sub = context.read<SubscriptionProvider>();
    final auth = context.read<AuthProvider>();
    switch (widget.planIndex) {
      case 0:
        await sub.activateTrial();
        await auth.creditSubscription(15, 'Trial VIP');
        break;
      case 1:
        await sub.activateMonthly();
        await auth.creditSubscription(45, 'Monthly VIP');
        break;
      case 2:
        await sub.activateAnnual();
        await auth.creditSubscription(120, 'Annual VIP');
        break;
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
        _txnId = 'TXN_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final price = plan['price'] as int;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: _isSuccess
          ? _buildSuccessReceipt()
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Order Summary Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['name'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${plan['duration']} Unlimited Access',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    Text(
                      '₹$price',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.starGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: AppTheme.divider),
                const SizedBox(height: 14),

                // Payment Options Title
                Text(
                  'Select Payment Method',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Payment Methods
                _PaymentTile(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Google Pay (UPI)',
                  subtitle: 'Fastest 1-tap payment',
                  isSelected: _selectedMethod == 0,
                  onTap: () => setState(() => _selectedMethod = 0),
                ),
                const SizedBox(height: 8),
                _PaymentTile(
                  icon: Icons.mobile_friendly_rounded,
                  title: 'PhonePe / Paytm UPI',
                  subtitle: 'All bank UPI IDs accepted',
                  isSelected: _selectedMethod == 1,
                  onTap: () => setState(() => _selectedMethod = 1),
                ),
                const SizedBox(height: 8),
                _PaymentTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Credit / Debit Card',
                  subtitle: 'Visa, Mastercard, RuPay',
                  isSelected: _selectedMethod == 2,
                  onTap: () => setState(() => _selectedMethod = 2),
                ),
                const SizedBox(height: 24),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Verifying with Bank Gateway...',
                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        : Text(
                            'Pay ₹$price Securely',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    '256-Bit SSL Encrypted · Instant Activation',
                    style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSuccessReceipt() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.successGreen.withValues(alpha: 0.15),
          ),
          child: const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 52),
        ),
        const SizedBox(height: 16),
        Text(
          'Payment Successful!',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.starGold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your ${widget.plan['name']} membership is now live.',
          style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBgLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: [
              _ReceiptRow('Transaction ID', _txnId),
              const Divider(color: AppTheme.divider, height: 16),
              _ReceiptRow('Plan Name', widget.plan['name'] as String),
              const Divider(color: AppTheme.divider, height: 16),
              _ReceiptRow('Amount Paid', '₹${widget.plan['price']} (Incl. GST)'),
              const Divider(color: AppTheme.divider, height: 16),
              _ReceiptRow('Status', 'Active'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('Return to AstroZen Home'),
          ),
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.royalPurple.withValues(alpha: 0.2) : AppTheme.cardBgLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.starGold : AppTheme.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.starGold : AppTheme.textMuted, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.starGold : AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label, value;
  const _ReceiptRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
