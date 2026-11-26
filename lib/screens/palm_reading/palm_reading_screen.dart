import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/astrozen_api_service.dart';
import '../../widgets/common/star_background.dart';
import 'dart:io';

class PalmReadingScreen extends StatefulWidget {
  const PalmReadingScreen({super.key});

  @override
  State<PalmReadingScreen> createState() => _PalmReadingScreenState();
}

class _PalmReadingScreenState extends State<PalmReadingScreen>
    with TickerProviderStateMixin {
  File? _palmImage;
  bool _isAnalyzing = false;
  late AnimationController _scanController;
  late Animation<double> _scanAnim;

  // Birth details inputs
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(_scanController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (_nameCtrl.text.isEmpty && auth.userName != null) {
        _nameCtrl.text = auth.userName!;
      }
      if (_dobCtrl.text.isEmpty) {
        _dobCtrl.text = '15/06/1996';
      }
      if (_timeCtrl.text.isEmpty) {
        _timeCtrl.text = '12:30 PM';
      }
      if (_placeCtrl.text.isEmpty) {
        _placeCtrl.text = 'New Delhi, India';
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _timeCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1920,
      imageQuality: 80,
    );
    if (img != null) {
      setState(() => _palmImage = File(img.path));
    }
  }

  Future<void> _analyzePalmAndKundli() async {
    if (_palmImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or select a photo of your palm first')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final reading = await AstrozenApiService.generatePalmReading(
        name: _nameCtrl.text.trim().isEmpty ? 'Cosmic Seeker' : _nameCtrl.text.trim(),
        dob: _dobCtrl.text.trim().isEmpty ? '15/06/1996' : _dobCtrl.text.trim(),
        time: _timeCtrl.text.trim().isEmpty ? '12:30 PM' : _timeCtrl.text.trim(),
        place: _placeCtrl.text.trim().isEmpty ? 'India' : _placeCtrl.text.trim(),
        palmImage: _palmImage,
      );

      if (mounted) {
        setState(() => _isAnalyzing = false);
        context.push('/palm-reading/result', extra: reading.toMap());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e. Please retry.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const StarBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
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
                      const Icon(Icons.auto_awesome_rounded, color: AppTheme.starGold, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Royal Vedic & Palm Reading',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Header Explanation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.royalPurple.withValues(alpha: 0.25),
                          AppTheme.cardBg,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.starGold.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.insights_rounded, color: AppTheme.starGold, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Combines your palm biometric lines with Vedic Kundli alignment to generate a full Hinglish reading & 9:16 Royal Infographic.',
                            style: GoogleFonts.outfit(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Palm Photo Container
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppTheme.royalPurple.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: _palmImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              children: [
                                Image.file(
                                  _palmImage!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                if (_isAnalyzing)
                                  AnimatedBuilder(
                                    animation: _scanAnim,
                                    builder: (context, child) => Positioned(
                                      top: _scanAnim.value * 260,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.goldGradient,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.starGold.withValues(alpha: 0.8),
                                              blurRadius: 16,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.roseGold.withValues(alpha: 0.15),
                                ),
                                child: const Icon(
                                  Icons.fingerprint_rounded,
                                  size: 56,
                                  color: AppTheme.roseGold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Capture Right Palm Photo',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Align right hand under clear light\nwith fingers naturally spread',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Image Picker Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined, size: 16),
                          label: const Text('Take Photo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textPrimary,
                            side: const BorderSide(color: AppTheme.divider),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined, size: 16),
                          label: const Text('Choose Photo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textPrimary,
                            side: const BorderSide(color: AppTheme.divider),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Birth Details Confirmation Section
                  Text(
                    'Confirm Birth Details for Kundli Integration',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.starGold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _nameCtrl,
                    style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.starGold, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dobCtrl,
                          style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'DOB (DD/MM/YYYY)',
                            prefixIcon: Icon(Icons.calendar_today_rounded, color: AppTheme.starGold, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _timeCtrl,
                          style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Birth Time',
                            prefixIcon: Icon(Icons.access_time_rounded, color: AppTheme.starGold, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _placeCtrl,
                    style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Birth Place',
                      prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.starGold, size: 18),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Generate CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _analyzePalmAndKundli,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.royalPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isAnalyzing
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
                                  'Synthesizing Palm & Kundli Intelligence...',
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Generate Royal Vedic Reading',
                                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
