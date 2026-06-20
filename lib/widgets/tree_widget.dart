import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/app_theme_preset.dart';

class TreeWidget extends StatelessWidget {
  final double progress;
  final TreeStyle style;
  final double size;

  const TreeWidget({
    super.key,
    required this.progress,
    required this.style,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.05,
      child: CustomPaint(
        painter: _TreePainter(progress: progress.clamp(0.0, 1.0), style: style),
      ),
    );
  }
}

class FocusProgressRing extends StatelessWidget {
  final double progress;
  final Widget child;
  final Color? color;
  final double size;

  const FocusProgressRing({
    super.key,
    required this.progress,
    required this.child,
    this.color,
    this.size = 248,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = color ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              color: ringColor,
              trackColor: ringColor.withValues(alpha: isDark ? 0.14 : 0.1),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const stroke = 9.0;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    if (progress > 0.01) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _TreePainter extends CustomPainter {
  final double progress;
  final TreeStyle style;

  _TreePainter({required this.progress, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height * 0.9;
    final growth = Curves.easeOutCubic.transform(progress);

    _drawGround(canvas, cx, groundY, size.width);

    if (growth < 0.04) {
      _drawSeed(canvas, cx, groundY - 4, growth / 0.04);
      return;
    }

    if (style.id == 'skin_pine') {
      _drawPine(canvas, cx, groundY, size, growth);
    } else if (style.id == 'skin_bamboo') {
      _drawBamboo(canvas, cx, groundY, size, growth);
    } else if (style.id == 'skin_sakura') {
      _drawSakura(canvas, cx, groundY, size, growth);
    } else {
      _drawOak(canvas, cx, groundY, size, growth);
    }

    if (progress >= 0.98) {
      _drawCompletionGlow(canvas, Offset(cx, groundY - size.height * 0.42), size.width * 0.34);
    }
  }

  void _drawGround(Canvas canvas, double cx, double groundY, double width) {
    final soilRect = Rect.fromCenter(center: Offset(cx, groundY + 6), width: width * 0.72, height: 16);
    final soilPaint = Paint()
      ..shader = ui.Gradient.linear(
        soilRect.topLeft,
        soilRect.bottomRight,
        [const Color(0xFF78350F).withValues(alpha: 0.25), const Color(0xFF92400E).withValues(alpha: 0.45)],
      );
    canvas.drawOval(soilRect, soilPaint);

    final grassPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = -3; i <= 3; i++) {
      final x = cx + i * 12.0;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, groundY + 2), width: 14, height: 8),
        math.pi,
        math.pi,
        false,
        grassPaint,
      );
    }
  }

  void _drawSeed(Canvas canvas, double cx, double cy, double t) {
    final seedPaint = Paint()..color = const Color(0xFF92400E);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 10, height: 7), seedPaint);
    if (t > 0.2) {
      final sproutPaint = Paint()..color = style.foliageLight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy - 8 * t), width: 3, height: 10 * t),
          const Radius.circular(2),
        ),
        sproutPaint,
      );
      canvas.drawCircle(Offset(cx, cy - 12 * t), 4 * t, sproutPaint);
    }
  }

  void _drawOak(Canvas canvas, double cx, double groundY, Size size, double growth) {
    final trunkH = size.height * (0.16 + growth * 0.24);
    final trunkW = size.width * (0.07 + growth * 0.035);
    final trunkTop = groundY - trunkH;

    _drawTrunk(canvas, cx, trunkTop, trunkW, trunkH);

    final blobs = [
      (0.0, 0.22, 1.0),
      (-0.14, 0.34, 0.82),
      (0.13, 0.36, 0.78),
      (0.0, 0.48, 0.68),
    ];

    for (final (ox, oy, scale) in blobs) {
      final layerT = ((growth - oy + 0.12) / 0.35).clamp(0.0, 1.0);
      if (layerT <= 0) continue;
      final r = size.width * 0.11 * scale * layerT;
      final cy = trunkTop - size.height * oy * growth;
      _drawFoliageBlob(canvas, Offset(cx + ox * size.width * 0.28 * growth, cy), r, style.foliageColor, style.foliageLight);
    }
  }

  void _drawPine(Canvas canvas, double cx, double groundY, Size size, double growth) {
    final trunkH = size.height * (0.12 + growth * 0.18);
    final trunkTop = groundY - trunkH;
    _drawTrunk(canvas, cx, trunkTop, size.width * 0.06, trunkH);

    for (var i = 0; i < 4; i++) {
      final layerT = ((growth * 4) - i).clamp(0.0, 1.0);
      if (layerT <= 0) continue;
      final tierY = trunkTop - i * size.height * 0.11 * growth;
      final halfW = size.width * (0.08 + i * 0.05) * layerT;
      final path = Path()
        ..moveTo(cx, tierY - size.height * 0.12 * layerT)
        ..lineTo(cx - halfW, tierY)
        ..lineTo(cx + halfW, tierY)
        ..close();
      final paint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, tierY - size.height * 0.12),
          Offset(cx, tierY),
          [style.foliageLight, style.foliageColor],
        );
      canvas.drawPath(path, paint);
    }
  }

  void _drawBamboo(Canvas canvas, double cx, double groundY, Size size, double growth) {
    final stalks = [-0.12, 0.0, 0.12];
    for (final ox in stalks) {
      final delay = ox.abs() * 0.15;
      final t = ((growth - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final x = cx + ox * size.width * 0.55;
      final h = size.height * (0.22 + t * 0.38);
      final top = groundY - h;
      final paint = Paint()..color = Color.lerp(style.trunkColor, style.foliageLight, 0.35)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 5, top, 10, h), const Radius.circular(5)),
        paint,
      );
      for (var j = 1; j <= 3; j++) {
        canvas.drawLine(Offset(x - 7, top + h * j / 4), Offset(x + 7, top + h * j / 4), paint..strokeWidth = 1.5);
      }
      _drawFoliageBlob(canvas, Offset(x, top - 8), 10 * t, style.foliageLight, style.foliageColor);
    }
  }

  void _drawSakura(Canvas canvas, double cx, double groundY, Size size, double growth) {
    _drawOak(canvas, cx, groundY, size, growth);
    if (growth < 0.35) return;
    final petalPaint = Paint()..color = const Color(0xFFF472B6).withValues(alpha: 0.85);
    final rng = math.Random(7);
    for (var i = 0; i < 6; i++) {
      final px = cx + (rng.nextDouble() - 0.5) * size.width * 0.5 * growth;
      final py = groundY - size.height * (0.25 + rng.nextDouble() * 0.35) * growth;
      canvas.drawCircle(Offset(px, py), 3 + rng.nextDouble() * 2, petalPaint);
    }
  }

  void _drawTrunk(Canvas canvas, double cx, double top, double width, double height) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, top + height / 2), width: width, height: height),
      Radius.circular(width * 0.35),
    );
    final trunkPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(cx - width / 2, top),
        Offset(cx + width / 2, top + height),
        [style.trunkColor.withValues(alpha: 0.9), Color.lerp(style.trunkColor, Colors.black, 0.25)!],
      );
    canvas.drawRRect(rect, trunkPaint);

    final highlight = Paint()..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - width * 0.18, top + height / 2), width: width * 0.18, height: height * 0.75),
        Radius.circular(width * 0.2),
      ),
      highlight,
    );
  }

  void _drawFoliageBlob(Canvas canvas, Offset center, double radius, Color dark, Color light) {
    if (radius <= 0) return;
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [light, dark],
        [0.0, 1.0],
      );
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.25, center.dy - radius * 0.2),
      radius * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  void _drawCompletionGlow(Canvas canvas, Offset center, double radius) {
    final glow = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [AppColors.coin.withValues(alpha: 0.22), Colors.transparent],
      );
    canvas.drawCircle(center, radius, glow);
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.style.id != style.id;
}
