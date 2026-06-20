import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/app_theme_preset.dart';

class TreeWidget extends StatelessWidget {
  final double progress;
  final TreeStyle style;
  final double size;

  const TreeWidget({
    super.key,
    required this.progress,
    required this.style,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size * 1.1,
      child: CustomPaint(
        painter: _TreePainter(progress: clamped, style: style),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final double progress;
  final TreeStyle style;

  _TreePainter({required this.progress, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height * 0.88;

    // Soil
    final soilPaint = Paint()..color = const Color(0xFF92400E).withValues(alpha: 0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, groundY + 8), width: size.width * 0.7, height: 18), soilPaint);

    final trunkHeight = size.height * (0.18 + progress * 0.22);
    final trunkWidth = size.width * (0.08 + progress * 0.04);
    final trunkTop = groundY - trunkHeight;

    final trunkPaint = Paint()..color = style.trunkColor;
    final trunkRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, trunkTop + trunkHeight / 2), width: trunkWidth, height: trunkHeight),
      const Radius.circular(8),
    );
    canvas.drawRRect(trunkRect, trunkPaint);

    if (progress < 0.05) {
      // Seed sprout
      final sproutPaint = Paint()..color = style.foliageLight;
      canvas.drawCircle(Offset(cx, trunkTop - 6), 6 + progress * 40, sproutPaint);
      return;
    }

    final layers = 3;
    for (var i = 0; i < layers; i++) {
      final layerProgress = ((progress * layers) - i).clamp(0.0, 1.0);
      if (layerProgress <= 0) continue;

      final radius = size.width * (0.12 + i * 0.1) * layerProgress;
      final cy = trunkTop - (i * size.height * 0.12 * layerProgress) - radius * 0.3;
      final color = Color.lerp(style.foliageColor, style.foliageLight, i / (layers - 1))!;

      final foliagePaint = Paint()..color = color.withValues(alpha: 0.85);
      canvas.drawCircle(Offset(cx, cy), radius, foliagePaint);

      final highlight = Paint()..color = Colors.white.withValues(alpha: 0.15);
      canvas.drawCircle(Offset(cx - radius * 0.2, cy - radius * 0.15), radius * 0.35, highlight);
    }

    if (progress >= 0.95) {
      final sparklePaint = Paint()..color = style.accentColor.withValues(alpha: 0.8);
      for (var i = 0; i < 5; i++) {
        final angle = i * math.pi * 2 / 5;
        final r = size.width * 0.28;
        canvas.drawCircle(
          Offset(cx + math.cos(angle) * r, trunkTop - size.height * 0.35 + math.sin(angle) * r * 0.5),
          3,
          sparklePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.style.id != style.id;
}
