import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/star_background.dart';

class ExpertCallScreen extends StatefulWidget {
  final String expertId;
  const ExpertCallScreen({super.key, required this.expertId});

  @override
  State<ExpertCallScreen> createState() => _ExpertCallScreenState();
}

class _ExpertCallScreenState extends State<ExpertCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isConnected = false;
  bool _isMuted = false;
  bool _isSpeaker = true;

  late Map<String, dynamic> _expert;

  static const List<Map<String, dynamic>> _experts = [
    {'id': '1', 'name': 'Pt. Rajesh Sharma', 'spec': 'Vedic Astrology', 'price': 15, 'icon': Icons.psychology_outlined},
    {'id': '2', 'name': 'Meera Devi Joshi', 'spec': 'Tarot & Numerology', 'price': 10, 'icon': Icons.auto_stories_outlined},
    {'id': '3', 'name': 'Acharya Suresh Kumar', 'spec': 'Palm Reading & KP', 'price': 20, 'icon': Icons.pan_tool_alt_outlined},
    {'id': '4', 'name': 'Dr. Priya Nair', 'spec': 'Vastu Shastra', 'price': 25, 'icon': Icons.villa_outlined},
    {'id': '5', 'name': 'Pt. Arvind Tiwari', 'spec': 'Lal Kitab & Nadi', 'price': 12, 'icon': Icons.self_improvement_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _expert = _experts.firstWhere(
      (e) => e['id'] == widget.expertId,
      orElse: () => _experts[0],
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Simulate connection delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isConnected = true);
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _endCall() {
    _timer?.cancel();
    final minutes = (_secondsElapsed / 60).ceil();
    final cost = minutes * (_expert['price'] as int);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Consultation Completed',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.starGold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Astrologer: ${_expert['name']}',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Call Duration: ${_formatDuration(_secondsElapsed)}',
              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              'Consultation Fee: ₹$cost (${_expert['price']}/min)',
              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Session notes & remedies synced to your profile.',
                      style: GoogleFonts.outfit(fontSize: 11.5, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const StarBackground(),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isConnected ? Icons.circle : Icons.wifi_protected_setup_rounded,
                              size: 10,
                              color: _isConnected ? AppTheme.successGreen : AppTheme.starGold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isConnected ? 'Connected' : 'Connecting...',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Text(
                          '₹${_expert['price']}/min',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.starGold, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),

                // Center Avatar & Waveform
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) => Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.royalPurple.withValues(alpha: 0.2),
                          border: Border.all(
                            color: AppTheme.starGold.withValues(alpha: 0.4 + 0.3 * _pulseController.value),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.royalPurple.withValues(alpha: 0.4 * _pulseController.value),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _expert['icon'] as IconData,
                            size: 64,
                            color: AppTheme.starGold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _expert['name'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _expert['spec'] as String,
                      style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.starGold),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isConnected ? _formatDuration(_secondsElapsed) : 'Calling Astrologer...',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: _isConnected ? AppTheme.successGreen : AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live Audio Waveform Simulation
                    if (_isConnected)
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(12, (index) {
                            final h = 10.0 + 25.0 * ((_pulseController.value * (index + 1)) % 1.0);
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              width: 3.5,
                              height: h,
                              decoration: BoxDecoration(
                                color: AppTheme.starGold.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),

                // Bottom Call Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mute
                      _CallControlButton(
                        icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        isActive: _isMuted,
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      // End Call
                      GestureDetector(
                        onTap: _endCall,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: AppTheme.errorRed,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.errorRed,
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 30),
                        ),
                      ),
                      // Speaker
                      _CallControlButton(
                        icon: _isSpeaker ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        label: 'Speaker',
                        isActive: _isSpeaker,
                        onTap: () => setState(() => _isSpeaker = !_isSpeaker),
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

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppTheme.starGold : AppTheme.cardBg,
              border: Border.all(color: AppTheme.divider),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.deepSpace : AppTheme.textPrimary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 11.5, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
