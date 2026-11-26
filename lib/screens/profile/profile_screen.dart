import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/common/star_background.dart';

class ProfileScreen extends StatefulWidget {
  final bool isTab;
  const ProfileScreen({super.key, this.isTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showApiKeyDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentKey = prefs.getString('gemini_api_key') ?? '';
    final ctrl = TextEditingController(text: currentKey);

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Google Gemini API Key',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.starGold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your Gemini API Key to enable real multimodal palmistry and live AI astrologer predictions directly from Google AI.',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              obscureText: true,
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
              decoration: const InputDecoration(
                hintText: 'AIzaSy...',
                prefixIcon: Icon(
                  Icons.key_rounded,
                  color: AppTheme.starGold,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await prefs.setString('gemini_api_key', ctrl.text.trim());
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gemini API Key saved successfully!'),
                  ),
                );
              }
            },
            child: const Text('Save Key'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.userName ?? '');
    String selectedZodiac = auth.userZodiac ?? 'Scorpio';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Profile',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Full Name',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Enter your name'),
              ),
              const SizedBox(height: 16),
              Text(
                'Zodiac Sign',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardBgLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedZodiac,
                    isExpanded: true,
                    dropdownColor: AppTheme.cardBgLight,
                    items: AppConstants.zodiacSigns.map((z) {
                      return DropdownMenuItem<String>(
                        value: z['name'] as String,
                        child: Row(
                          children: [
                            Text(
                              z['symbol'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppTheme.starGold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              z['name'] as String,
                              style: GoogleFonts.outfit(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedZodiac = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: AppTheme.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await auth.updateProfile(
                  name: nameCtrl.text.trim().isEmpty
                      ? 'Cosmic Seeker'
                      : nameCtrl.text.trim(),
                  zodiac: selectedZodiac,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of AstroZen?',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) context.go('/auth');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sub = context.watch<SubscriptionProvider>();

    final userZodiacName = auth.userZodiac ?? 'Scorpio';
    final signData = AppConstants.zodiacSigns.firstWhere(
      (s) =>
          (s['name'] as String).toLowerCase() == userZodiacName.toLowerCase(),
      orElse: () => AppConstants.zodiacSigns[7],
    );
    final signColor = Color(signData['color'] as int);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (!widget.isTab) const StarBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── App Bar ─────────────────────────────────────────
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    'Profile & Settings',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: AppTheme.starGold,
                      ),
                      onPressed: () => _showEditProfileDialog(context, auth),
                    ),
                  ],
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Profile Header Card ──────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              signColor.withValues(alpha: 0.2),
                              AppTheme.cardBg,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: signColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    signColor.withValues(alpha: 0.8),
                                    signColor.withValues(alpha: 0.2),
                                  ],
                                ),
                                border: Border.all(
                                  color: signColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  signData['symbol'] as String,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
                                    auth.userName ?? 'Cosmic Seeker',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    auth.userPhone != null &&
                                            auth.userPhone!.isNotEmpty
                                        ? '+91 ${auth.userPhone}'
                                        : 'Guest User',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: signColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: signColor.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '${signData['name']} · ${signData['element']}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: signColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Horoscope Birth Chart Details Card ───────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.starGold.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.royalPurple.withValues(alpha: 0.3),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppTheme.starGold,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Horoscope Birth Chart',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    auth.userDob != null &&
                                            auth.userDob!.isNotEmpty
                                        ? '${auth.userDob} • ${auth.userTob ?? "12:00 PM"} • ${auth.userPob ?? "India"}'
                                        : 'Set DOB, Time & City for 100% precision',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.starGold,
                                foregroundColor: AppTheme.deepSpace,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => context.push(
                                '/horoscope-registration',
                                extra: true,
                              ),
                              child: Text(
                                auth.userDob != null ? 'Edit' : 'Register',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Astrologer Consultation Wallet Card ──────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.starGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.starGold.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: AppTheme.starGold,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Consultation Wallet',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${auth.walletMinutes} Minutes Available',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppTheme.starGold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.royalPurple,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => context.go('/subscribe'),
                              child: Text(
                                'Recharge',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Subscription Status Card ─────────────────
                      GestureDetector(
                        onTap: () => context.go('/subscribe'),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: sub.isSubscribed
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF2A1B4E),
                                      Color(0xFF13163A),
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFF2D1040),
                                      Color(0xFF1A1333),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sub.isSubscribed
                                  ? AppTheme.starGold
                                  : AppTheme.royalPurple,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: sub.isSubscribed
                                      ? AppTheme.starGold.withValues(alpha: 0.2)
                                      : AppTheme.royalPurple.withValues(
                                          alpha: 0.3,
                                        ),
                                ),
                                child: Icon(
                                  sub.isSubscribed
                                      ? Icons.workspace_premium_rounded
                                      : Icons.auto_awesome_rounded,
                                  color: sub.isSubscribed
                                      ? AppTheme.starGold
                                      : AppTheme.roseGold,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.isSubscribed
                                          ? 'Membership: ${sub.currentPlan.toUpperCase()}'
                                          : 'Unlock AstroZen Premium',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      sub.isSubscribed
                                          ? 'Active until ${sub.expiryDate != null ? "${sub.expiryDate!.day}/${sub.expiryDate!.month}/${sub.expiryDate!.year}" : "Ongoing"}'
                                          : 'Full Kundli, Palm Readings & Expert Perks from ₹11',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppTheme.starGold,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Section: Preferences ─────────────────────
                      _SectionHeader(
                        title: 'Preferences',
                        icon: Icons.tune_rounded,
                      ),
                      const SizedBox(height: 10),
                      Consumer<NotificationProvider>(
                        builder: (context, notif, _) {
                          return Container(
                            decoration: AppTheme.glassCard,
                            child: Column(
                              children: [
                                SwitchListTile(
                                  title: Text(
                                    'Daily Horoscope Alerts',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Receive Gemini celestial guidance at dawn',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  value: notif.dailyHoroscopeAlert,
                                  activeColor: AppTheme.starGold,
                                  onChanged: (val) =>
                                      notif.updateSettings(dailyHoroscope: val),
                                ),
                                const Divider(
                                  color: AppTheme.divider,
                                  height: 1,
                                ),
                                SwitchListTile(
                                  title: Text(
                                    'Planetary Transit Insights',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Get alerted on major planetary shifts & Rahu Kaal',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  value: notif.rahuKaalAlert,
                                  activeColor: AppTheme.starGold,
                                  onChanged: (val) =>
                                      notif.updateSettings(rahuKaal: val),
                                ),
                                const Divider(
                                  color: AppTheme.divider,
                                  height: 1,
                                ),
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.starGold.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.bolt_rounded,
                                      color: AppTheme.starGold,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    'Test Gemini Daily Alert',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Generates & triggers today\'s horoscope via Gemini API',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  trailing: notif.isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.starGold,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 14,
                                          color: AppTheme.starGold,
                                        ),
                                  onTap: notif.isLoading
                                      ? null
                                      : () async {
                                          final res = await notif
                                              .generateTodayHoroscope();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  res != null
                                                      ? '🔔 Gemini Daily Horoscope push notification delivered to status bar!'
                                                      : 'Unable to connect to Gemini engine. Please check backend.',
                                                ),
                                                backgroundColor:
                                                    AppTheme.royalPurple,
                                              ),
                                            );
                                          }
                                        },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // ── Section: Astrological Modules ───────────
                      _SectionHeader(
                        title: 'Astrological Hub',
                        icon: FontAwesomeIcons.moon,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: AppTheme.glassCard,
                        child: Column(
                          children: [
                            _ProfileTile(
                              icon: Icons.favorite_border_rounded,
                              title: 'Kundli Milan (36 Guna Matching)',
                              subtitle: 'Ashtakoot relationship compatibility',
                              onTap: () => context.push('/kundli/matching'),
                            ),
                            const Divider(color: AppTheme.divider, height: 1),
                            _ProfileTile(
                              icon: Icons.calendar_today_rounded,
                              title: 'Saved Birth Charts',
                              subtitle:
                                  'View generated Kundlis & Navamsa profiles',
                              onTap: () => context.go('/kundli'),
                            ),
                            const Divider(color: AppTheme.divider, height: 1),
                            _ProfileTile(
                              icon: Icons.pan_tool_outlined,
                              title: 'Saved Palm Scans',
                              subtitle:
                                  'Review previous biometric palm analysis',
                              onTap: () => context.go('/palm-reading'),
                            ),
                            const Divider(color: AppTheme.divider, height: 1),
                            _ProfileTile(
                              icon: Icons.explore_outlined,
                              title: 'Vastu Direction Reports',
                              subtitle:
                                  'Stored home layout scores and remedies',
                              onTap: () => context.go('/vastu'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Section: Support & Info ───────────────────
                      _SectionHeader(
                        title: 'Support & Trust',
                        icon: Icons.shield_outlined,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: AppTheme.glassCard,
                        child: Column(
                          children: [
                            _ProfileTile(
                              icon: Icons.key_rounded,
                              title: 'AI Engine: Google Gemini Key',
                              subtitle: 'Configure custom Gemini API key',
                              onTap: () => _showApiKeyDialog(context),
                            ),
                            const Divider(color: AppTheme.divider, height: 1),
                            _ProfileTile(
                              icon: Icons.lock_outline_rounded,
                              title: 'Privacy & Astrological Ethics',
                              subtitle: 'End-to-end encrypted consultations',
                              onTap: () {},
                            ),
                            const Divider(color: AppTheme.divider, height: 1),
                            _ProfileTile(
                              icon: Icons.info_outline_rounded,
                              title: 'About AstroZen AI',
                              subtitle:
                                  'Version 1.0.0 (Vedic Ephemeris Engine)',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Logout Button ────────────────────────────
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _confirmLogout(context, auth),
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppTheme.errorRed,
                            size: 18,
                          ),
                          label: Text(
                            'Sign Out of AstroZen',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.errorRed,
                            ),
                          ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.starGold),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cardBgLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.starGold, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 12,
        color: AppTheme.textMuted,
      ),
      onTap: onTap,
    );
  }
}
