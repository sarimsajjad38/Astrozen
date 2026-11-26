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
  late final AnimationController _controller;

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
    return RepaintBoundary(
      child: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _StaticStarPainter(_controller.value),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _StarPoint {
  final double xPercent;
  final double yPercent;
  final double radius;
  final double phase;

  const _StarPoint(this.xPercent, this.yPercent, this.radius, this.phase);
}

class _StaticStarPainter extends CustomPainter {
  final double progress;
  static final Paint _paint = Paint()..style = PaintingStyle.fill;

  // Pre-computed static points - ZERO runtime Random instantiation or allocations
  static final List<_StarPoint> _stars = () {
    final list = <_StarPoint>[];
    final rand = math.Random(42);
    for (int i = 0; i < 45; i++) {
      list.add(
        _StarPoint(
          rand.nextDouble(),
          rand.nextDouble(),
          rand.nextDouble() * 1.3 + 0.6,
          (i * 0.4) % (2 * math.pi),
        ),
      );
    }
    return List<_StarPoint>.unmodifiable(list);
  }();

  _StaticStarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final w = size.width;
    final h = size.height;
    final twoPi = 2 * math.pi;

    for (final s in _stars) {
      final alpha = (math.sin(progress * twoPi + s.phase) + 1.0) * 0.35 + 0.15;
      _paint.color = Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(
        Offset(s.xPercent * w, s.yPercent * h),
        s.radius,
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StaticStarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
