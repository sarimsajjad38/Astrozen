import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/astrozen_api_service.dart';
import '../../widgets/common/star_background.dart';

class ExpertChatScreen extends StatefulWidget {
  final String expertId;
  const ExpertChatScreen({super.key, required this.expertId});

  @override
  State<ExpertChatScreen> createState() => _ExpertChatScreenState();
}

class _ExpertChatScreenState extends State<ExpertChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  late Map<String, dynamic> _expert;

  final List<Map<String, dynamic>> _messages = [];

  static const List<Map<String, dynamic>> _experts = [
    {
      'id': '1',
      'name': 'Pt. Rajesh Sharma',
      'icon': Icons.psychology_outlined,
      'spec': 'Vedic Astrology',
      'price': 15,
      'online': true,
      'welcome': 'Namaste! Main Pandit Rajesh Sharma hoon. Kripya apna prashna ya birth details share karein. Main aapke grahon ki sthiti dekh kar margdarshan karunga.',
    },
    {
      'id': '2',
      'name': 'Meera Devi Joshi',
      'icon': Icons.auto_stories_outlined,
      'spec': 'Tarot & Numerology',
      'price': 10,
      'online': true,
      'welcome': 'Namaste dear soul! Main Meera Devi hoon. Tarot cards aur numerology ke dwara aapki life aur relationships ka satya janenge. Poochiye jo aapke dil me hai.',
    },
    {
      'id': '3',
      'name': 'Acharya Suresh Kumar',
      'icon': Icons.pan_tool_alt_outlined,
      'spec': 'Palm Reading & KP',
      'price': 20,
      'online': true,
      'welcome': 'Pranam! Acharya Suresh Kumar here. KP astrology aur Hastarekha se samay aur events ka accurate timing nikalenge. Apna sawal batayein.',
    },
    {
      'id': '4',
      'name': 'Dr. Priya Nair',
      'icon': Icons.villa_outlined,
      'spec': 'Vastu Shastra',
      'price': 25,
      'online': true,
      'welcome': 'Welcome! Dr. Priya Nair here. Aapke ghar ya workplace ki negative urja ko Vastu remedies ke zariye positive prosperity me transform karenge.',
    },
    {
      'id': '5',
      'name': 'Pt. Arvind Tiwari',
      'icon': Icons.self_improvement_outlined,
      'spec': 'Lal Kitab & Nadi',
      'price': 12,
      'online': true,
      'welcome': 'Namaskar! Lal Kitab ke saral aur asarkari upaayon se har rukawat ka samadhan sambhav hai. Kripya apni samasya batayein.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _expert = _experts.firstWhere(
      (e) => e['id'] == widget.expertId,
      orElse: () => _experts[0],
    );

    _messages.add({
      'sender': 'expert',
      'text': _expert['welcome'] as String,
      'time': 'Just now',
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': userMsg,
        'time': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
      });
      _isTyping = true;
    });

    _scrollToBottom();

    String reply = '';
    try {
      reply = await AstrozenApiService.chatWithAstrologer(
        expertName: _expert['name'] as String? ?? 'Vedic Astrologer',
        expertSpec: _expert['spec'] as String? ?? 'Vedic Astrology',
        message: userMsg,
      );
    } catch (_) {
      reply = _generateAstrologerReply(userMsg);
    }

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add({
        'sender': 'expert',
        'text': reply,
        'time': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
      });
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateAstrologerReply(String query) {
    final q = query.toLowerCase();
    final auth = context.read<AuthProvider>();
    final userName = auth.userName ?? 'Jatak';

    if (q.contains('career') || q.contains('job') || q.contains('promotion')) {
      return 'Dekhiye $userName ji, aapki Kundli me 10th house me Brihaspati (Jupiter) ka shubh dhyan hai. 2026 ke madhya se career me promotion aur sthirta ke shubh yog shuru ho rahe hain. Roz subah Surya Dev ko arghya dein aur peele kapde me chane ki daal daan karein.';
    } else if (q.contains('marriage') || q.contains('love') || q.contains('shadi')) {
      return 'Vivah ke sambandh me aapka Shukra (Venus) bohot strong hai. Shubh vivah ke yog agle 12 se 18 mahino me ban rahe hain. Ek understanding aur caring partner milega. Somvar ko Shivling par kacha doodh arpit karein.';
    } else if (q.contains('money') || q.contains('wealth') || q.contains('paisa')) {
      return 'Dhan aagman ke liye aapka secondary house kafi balwaan hai. Kharchon par thoda santulan banaye rakhein. Shukravar ke din Laxmi Ji ke samne ghee ka deepak jalayein aur Shri Suktam ka path karein.';
    } else if (q.contains('gemstone') || q.contains('ratna')) {
      return 'Aapke grahon ki sthiti ke anusar Yellow Sapphire (Pukhraj) ya ek natural Moti (Pearl) dharan karna aapke mann aur career dono ke liye atyant shubh rahega.';
    } else {
      return 'Aapke prashna par dhyan dete hue grahon ki dasha kehti hai ki aane wala samay sakaratmak badlav lekar aayega. Apne lakshya par focus rakhein aur niyamit roop se Om Namah Shivaya ka jaap karein.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final quickPrompts = [
      'Career growth kab hogi?',
      'Marriage timing & partner nature?',
      'Dhan aur financial stability?',
      'Meri Kundli ke shubh ratna?',
    ];

    return Scaffold(
      body: Stack(
        children: [
          const StarBackground(),
          SafeArea(
            child: Column(
              children: [
                // ── Top Header ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    border: const Border(bottom: BorderSide(color: AppTheme.divider, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBgLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Stack(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.royalPurple.withValues(alpha: 0.3),
                              border: Border.all(color: AppTheme.starGold, width: 1.2),
                            ),
                            child: Center(
                              child: Icon(
                                _expert['icon'] as IconData,
                                size: 20,
                                color: AppTheme.starGold,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppTheme.successGreen,
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: AppTheme.cardBg, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _expert['name'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Online · ₹${_expert['price']}/min · Verified',
                              style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.starGold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_rounded, color: AppTheme.celestialTeal),
                        onPressed: () => context.push('/experts/call/${widget.expertId}'),
                      ),
                    ],
                  ),
                ),

                // ── Messages List ───────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final m = _messages[i];
                      final isUser = m['sender'] == 'user';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUser) ...[
                              Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.royalPurple.withValues(alpha: 0.3),
                                ),
                                child: Icon(_expert['icon'] as IconData, size: 14, color: AppTheme.starGold),
                              ),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: isUser
                                      ? AppTheme.purpleGradient
                                      : LinearGradient(
                                          colors: [
                                            AppTheme.cardBgLight,
                                            AppTheme.cardBg,
                                          ],
                                        ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                                    bottomRight: Radius.circular(isUser ? 4 : 18),
                                  ),
                                  border: Border.all(
                                    color: isUser
                                        ? AppTheme.starGold.withValues(alpha: 0.3)
                                        : AppTheme.divider,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m['text'] as String,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13.5,
                                        color: AppTheme.textPrimary,
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      m['time'] as String,
                                      style: GoogleFonts.outfit(
                                        fontSize: 9.5,
                                        color: isUser ? Colors.white70 : AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ── Typing Indicator ────────────────────────────────
                if (_isTyping)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.starGold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_expert['name']} is studying your chart...',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.starGold),
                        ),
                      ],
                    ),
                  ),

                // ── Quick Suggestions ───────────────────────────────
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: quickPrompts.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => _sendMessage(quickPrompts[i]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBgLight,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.royalPurple.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          quickPrompts[i],
                          style: GoogleFonts.outfit(fontSize: 11.5, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Input Bar ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    border: const Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Type your question...',
                            filled: true,
                            fillColor: AppTheme.cardBgLight,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _sendMessage(_messageController.text),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.purpleGradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.starGold.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        ),
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
