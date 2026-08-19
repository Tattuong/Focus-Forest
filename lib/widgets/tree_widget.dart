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
    final resolved = style.themed(Theme.of(context).colorScheme);
    return SizedBox(
      width: size,
      height: size * 1.08,
      child: CustomPaint(
        painter: _TreePainter(progress: progress.clamp(0.0, 1.0), style: resolved),
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
              trackColor: ringColor.withValues(alpha: isDark ? 0.16 : 0.12),
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
    final radius = size.width / 2 - 14;
    const stroke = 6.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (progress > 0.005) {
      final sweep = math.pi * 2 * progress;
      final arc = Paint()
        ..shader = ui.Gradient.sweep(
          center,
          [color.withValues(alpha: 0.55), color, Color.lerp(color, Colors.white, 0.45)!],
          [0.0, progress * 0.55, progress],
          TileMode.clamp,
          -math.pi / 2,
          sweep,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweep, false, arc);
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
    final groundY = size.height * 0.88;
    final growth = Curves.easeOutCubic.transform(progress);

    _drawGround(canvas, cx, groundY, size.width);

    if (growth < 0.08) {
      _drawSeed(canvas, cx, groundY - 2, (growth / 0.08).clamp(0.0, 1.0));
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
      _drawCompletionGlow(canvas, Offset(cx, groundY - size.height * 0.42), size.width * 0.38);
    }
  }

  void _drawGround(Canvas canvas, double cx, double groundY, double width) {
    final soil = Rect.fromCenter(center: Offset(cx, groundY + 5), width: width * 0.62, height: 14);
    canvas.drawOval(
      soil,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, groundY + 4),
          width * 0.32,
          [const Color(0xFF8B5E34).withValues(alpha: 0.45), const Color(0xFF8B5E34).withValues(alpha: 0.08)],
        ),
    );

    final blade = Paint()
      ..color = const Color(0xFF2D6A4F).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    const xs = [-22.0, -14.0, -7.0, 7.0, 15.0, 23.0];
    for (final dx in xs) {
      final lean = dx < 0 ? -2.2 : 2.2;
      canvas.drawLine(Offset(cx + dx, groundY + 1), Offset(cx + dx + lean, groundY - 7), blade);
    }
  }

  void _drawSeed(Canvas canvas, double cx, double cy, double t) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 11, height: 8),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx - 5, cy),
          Offset(cx + 5, cy + 4),
          const [Color(0xFFA16207), Color(0xFF713F12)],
        ),
    );
    if (t <= 0.15) return;

    final stem = Paint()
      ..color = const Color(0xFF40916C)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - 12 * t), stem);

    _drawLeaf(canvas, Offset(cx, cy - 8 * t), 7 * t, -0.7, const Color(0xFF52B788));
    _drawLeaf(canvas, Offset(cx, cy - 10 * t), 7 * t, 0.7, const Color(0xFF2D6A4F));
  }

  void _drawLeaf(Canvas canvas, Offset origin, double len, double angle, Color color) {
    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(
        origin.dx + math.cos(angle) * len * 0.55,
        origin.dy + math.sin(angle) * len - 4,
        origin.dx + math.cos(angle) * len,
        origin.dy + math.sin(angle) * len * 0.2,
      )
      ..quadraticBezierTo(
        origin.dx + math.cos(angle) * len * 0.4,
        origin.dy + 2,
        origin.dx,
        origin.dy,
      );
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawOak(Canvas canvas, double cx, double groundY, Size size, double growth) {
    final trunkH = size.height * (0.22 + growth * 0.18);
    final baseW = size.width * (0.11 + growth * 0.03);
    final topW = baseW * 0.55;
    final trunkTop = groundY - trunkH;
    _drawTaperedTrunk(canvas, cx, trunkTop, trunkH, baseW, topW);

    final canopyCenter = Offset(cx, trunkTop - size.height * 0.02);
    final canopyScale = 0.42 + growth * 0.58;

    final clusters = <(Offset, double, double)>[
      (const Offset(0, -0.06), 1.0, 0.18),
      (const Offset(-0.22, 0.04), 0.78, 0.28),
      (const Offset(0.24, 0.06), 0.74, 0.32),
      (const Offset(-0.12, 0.16), 0.62, 0.42),
      (const Offset(0.14, 0.18), 0.58, 0.46),
      (const Offset(0, -0.22), 0.7, 0.52),
      (const Offset(-0.18, -0.12), 0.55, 0.6),
      (const Offset(0.2, -0.1), 0.52, 0.64),
    ];

    for (final (offset, scale, appearAt) in clusters) {
      final layerT = ((growth - appearAt + 0.22) / 0.4).clamp(0.0, 1.0);
      if (layerT <= 0) continue;
      final r = size.width * 0.22 * scale * canopyScale * layerT;
      _drawCanopyCluster(
        canvas,
        canopyCenter + Offset(offset.dx * size.width * canopyScale, offset.dy * size.height * canopyScale),
        r,
      );
    }
  }

  void _drawCanopyCluster(Canvas canvas, Offset center, double radius) {
    if (radius <= 1) return;
    final dark = Color.lerp(style.foliageColor, const Color(0xFF081C15), 0.18)!;
    final mid = style.foliageColor;
    final light = Color.lerp(style.foliageLight, const Color(0xFFD8F3DC), 0.18)!;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 2.05, height: radius * 1.72),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(center.dx - radius * 0.22, center.dy - radius * 0.28),
          radius * 1.35,
          [light, mid, dark],
          const [0.0, 0.45, 1.0],
        ),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.28, center.dy - radius * 0.32),
        width: radius * 0.72,
        height: radius * 0.48,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
  }

  void _drawPine(Canvas canvas, double cx, double groundY, Size size, double growth) {
    final trunkH = size.height * (0.16 + growth * 0.16);
    _drawTaperedTrunk(canvas, cx, groundY - trunkH, trunkH, size.width * 0.08, size.width * 0.045);

    for (var i = 0; i < 4; i++) {
      final layerT = ((growth * 4.2) - i).clamp(0.0, 1.0);
      if (layerT <= 0) continue;
      final y = groundY - trunkH - i * size.height * 0.12 * growth;
      final w = size.width * (0.34 - i * 0.055) * layerT;
      final h = size.height * 0.16 * layerT;
      final path = Path()
        ..moveTo(cx, y - h)
        ..quadraticBezierTo(cx - w * 0.15, y - h * 0.2, cx - w, y + h * 0.12)
        ..lineTo(cx + w, y + h * 0.12)
        ..quadraticBezierTo(cx + w * 0.15, y - h * 0.2, cx, y - h)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(cx, y - h),
            Offset(cx, y + h * 0.12),
            [style.foliageLight, style.foliageColor],
          ),
      );
    }
  }

  void _drawBamboo(Canvas canvas, double cx, double groundY, Size size, double growth) {
    final stalks = [-0.16, 0.0, 0.18];
    for (final ox in stalks) {
      final delay = ox.abs() * 0.12;
      final t = ((growth - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final x = cx + ox * size.width * 0.5;
      final h = size.height * (0.28 + t * 0.36);
      final top = groundY - h;
      final paint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(x - 5, top),
          Offset(x + 5, top),
          [Color.lerp(style.trunkColor, Colors.white, 0.25)!, style.trunkColor],
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 4.5, top, 9, h), const Radius.circular(4)),
        paint,
      );
      final knot = Paint()
        ..color = Color.lerp(style.trunkColor, Colors.black, 0.2)!
        ..strokeWidth = 1.4;
      for (var j = 1; j <= 3; j++) {
        canvas.drawLine(Offset(x - 6, top + h * j / 4), Offset(x + 6, top + h * j / 4), knot);
      }
      _drawLeaf(canvas, Offset(x, top + 6), 12 * t, -1.1, style.foliageLight);
      _drawLeaf(canvas, Offset(x, top + 10), 11 * t, 1.0, style.foliageColor);
    }
  }

  void _drawSakura(Canvas canvas, double cx, double groundY, Size size, double growth) {
    _drawOak(canvas, cx, groundY, size, growth);
    if (growth < 0.4) return;
    final rng = math.Random(11);
    for (var i = 0; i < 10; i++) {
      final px = cx + (rng.nextDouble() - 0.5) * size.width * 0.55 * growth;
      final py = groundY - size.height * (0.28 + rng.nextDouble() * 0.38) * growth;
      canvas.drawCircle(
        Offset(px, py),
        2.4 + rng.nextDouble() * 1.8,
        Paint()..color = const Color(0xFFF9A8D4).withValues(alpha: 0.9),
      );
    }
  }

  void _drawTaperedTrunk(Canvas canvas, double cx, double top, double height, double baseW, double topW) {
    final path = Path()
      ..moveTo(cx - topW / 2, top)
      ..lineTo(cx + topW / 2, top)
      ..lineTo(cx + baseW / 2, top + height)
      ..quadraticBezierTo(cx, top + height + 3, cx - baseW / 2, top + height)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx - baseW / 2, top),
          Offset(cx + baseW / 2, top + height),
          [
            Color.lerp(style.trunkColor, const Color(0xFFD6A36A), 0.28)!,
            style.trunkColor,
            Color.lerp(style.trunkColor, Colors.black, 0.22)!,
          ],
          const [0.0, 0.45, 1.0],
        ),
    );

    canvas.drawPath(
      Path()
        ..moveTo(cx - topW * 0.18, top + 4)
        ..lineTo(cx - baseW * 0.18, top + height * 0.85)
        ..lineTo(cx - baseW * 0.08, top + height * 0.85)
        ..lineTo(cx - topW * 0.02, top + 4)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.14),
    );
  }

  void _drawCompletionGlow(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [AppColors.coin.withValues(alpha: 0.18), Colors.transparent],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.style.id != style.id;
}
