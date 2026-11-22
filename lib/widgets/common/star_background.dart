import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'dart:math' as math;

class StarBackground extends StatefulWidget {
  const StarBackground({super.key});

  @override
  State<StarBackground> createState() => _StarBackgroundState();
}

class _StarBackgroundState extends State<StarBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _StarPainter(_controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double progress;
  _StarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    for (int i = 0; i < 60; i++) {
      final rand = math.Random(i * 137);
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 1.5 + 0.5;

      final phase = (i * 0.3) % (2 * math.pi);
      final alpha = (math.sin(progress * 2 * math.pi + phase) + 1) / 2 * 0.7 + 0.2;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
