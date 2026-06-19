// LIAQH LOADERS — built around the original HYBRID logo mark + the LIAQH word.
// Pure Flutter, no external packages. Drop this file in lib/ and use any widget,
// e.g.  const Center(child: LiaqhHybridLoader())
import 'dart:math' as math;
import 'package:flutter/material.dart';

// Brand palette
const Color kLiaqhTerra = Color(0xFFD97757);
const Color kLiaqhAmber = Color(0xFFE8A030);
const Color kLiaqhGold  = Color(0xFFF2C94C);

// ─────────────────────────────────────────────────────────────
// HYBRID LOGO PAINTER — the rounded terracotta square, the nuqta dot,
// and the L/ل stroke. `draw` (0..1) controls how much of the stroke is
// drawn; `dotScale` animates the dot.
// ─────────────────────────────────────────────────────────────
class HybridLogoPainter extends CustomPainter {
  final double draw;     // 0..1 portion of the L stroke drawn
  final double dotScale; // nuqta scale
  final Color bg;
  HybridLogoPainter({this.draw = 1, this.dotScale = 1, this.bg = kLiaqhTerra});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100; // artwork is authored in a 100×100 box
    canvas.save();
    canvas.scale(s);

    // background rounded square
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3, 3, 94, 94), const Radius.circular(21),
    );
    canvas.drawRRect(rrect, Paint()..color = bg);

    // soft top-left highlight
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.5, -0.6),
          radius: 0.9,
          colors: [Color(0x2EFFFFFF), Color(0x00FFFFFF)],
        ).createShader(const Rect.fromLTWH(3, 3, 94, 94)),
    );

    // L/ل stroke (drawn progressively)
    final path = Path()
      ..moveTo(59, 26)
      ..lineTo(59, 63)
      ..cubicTo(59, 74, 43, 81, 27, 73);
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round;
    final d = draw.clamp(0.0, 1.0);
    if (d > 0) {
      for (final m in path.computeMetrics()) {
        canvas.drawPath(m.extractPath(0, m.length * d), stroke);
      }
    }

    // nuqta dot
    if (dotScale > 0) {
      canvas.drawCircle(const Offset(59, 17), 5.8 * dotScale, Paint()..color = Colors.white);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HybridLogoPainter old) =>
      old.draw != draw || old.dotScale != dotScale || old.bg != bg;
}

/// LIAQH wordmark + Arabic لياقة
class _Wordmark extends StatelessWidget {
  const _Wordmark();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('LIAQH',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 6)),
        SizedBox(height: 2),
        Text('لياقة',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: kLiaqhTerra, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 1. SPLASH (recommended) — logo stroke draws in + nuqta pops,
//    wordmark, and an indeterminate progress bar. Great app splash.
// ─────────────────────────────────────────────────────────────
class LiaqhHybridLoader extends StatefulWidget {
  final double logoSize;
  const LiaqhHybridLoader({super.key, this.logoSize = 108});

  @override
  State<LiaqhHybridLoader> createState() => _LiaqhHybridLoaderState();
}

class _LiaqhHybridLoaderState extends State<LiaqhHybridLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = _c.value;
            // 0→0.45 draw, 0.45→0.65 hold, 0.65→1 erase
            double draw;
            if (t < 0.45) {
              draw = t / 0.45;
            } else if (t < 0.65) {
              draw = 1;
            } else {
              draw = 1 - (t - 0.65) / 0.35;
            }
            final dot = (t < 0.22) ? (t / 0.22) : (t > 0.85 ? (1 - (t - 0.85) / 0.15) : 1.0);
            return CustomPaint(
              size: Size.square(widget.logoSize),
              painter: HybridLogoPainter(draw: draw, dotScale: dot.clamp(0.0, 1.0)),
            );
          },
        ),
        const SizedBox(height: 16),
        // pulsing wordmark
        AnimatedBuilder(
          animation: _c,
          builder: (_, child) {
            final p = 0.5 + 0.5 * math.sin(_c.value * 2 * math.pi); // 0..1
            final opacity = 0.45 + 0.55 * p;
            final scale = 0.97 + 0.03 * p;
            return Opacity(
              opacity: opacity,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: const _Wordmark(),
        ),
      ],
    );
  }
}
