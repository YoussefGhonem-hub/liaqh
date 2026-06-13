import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Future<bool> Function() onCheck;
  final void Function(bool loggedIn) onDone;

  const SplashScreen({super.key, required this.onCheck, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Spinning outer hex — 3 s loop
  late AnimationController _spin;
  // Pulsing "L" — 1.8 s loop
  late AnimationController _pulse;
  // Staggered entrance (letters + underline + arabic) — 2 s one-shot
  late AnimationController _enter;

  static const _orange = Color(0xFFD97757);
  static const _bg = Color(0xFF1C1714);
  static const _letters = ['L', 'I', 'A', 'Q', 'H'];
  // delays in seconds for each letter (from HTML)
  static const _delays = [0.2, 0.38, 0.56, 0.74, 0.92];

  @override
  void initState() {
    super.initState();

    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..forward();

    // Run auth check after animation has had time to show
    widget.onCheck().then((loggedIn) {
      if (mounted) widget.onDone(loggedIn);
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    _enter.dispose();
    super.dispose();
  }

  Animation<double> _letterAnim(int i) {
    final start = _delays[i] / 2.2;
    final end = (_delays[i] + 0.5) / 2.2;
    return CurvedAnimation(
      parent: _enter,
      curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
          curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Spinning hex ring + pulsing L ───────────────────────
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer spinning hex rings
                  AnimatedBuilder(
                    animation: _spin,
                    builder: (_, __) => CustomPaint(
                      size: const Size(110, 110),
                      painter: _HexRingPainter(_spin.value * 2 * math.pi),
                    ),
                  ),
                  // Pulsing "L"
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) {
                      final scale = 1.0 - 0.12 * _pulse.value;
                      final opacity = 1.0 - 0.4 * _pulse.value;
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: const Text(
                            'L',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: _orange,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── LIAQH letters staggered ──────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_letters.length, (i) {
                return AnimatedBuilder(
                  animation: _letterAnim(i),
                  builder: (_, __) {
                    final t = _letterAnim(i).value;
                    final color = Color.lerp(
                      const Color(0xFFE89B82), _orange, t);
                    return Transform.translate(
                      offset: Offset(0, (1 - t) * 10),
                      child: Opacity(
                        opacity: t,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Text(
                            _letters[i],
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 8),

            // ── Expanding underline ───────────────────────────────────
            AnimatedBuilder(
              animation: CurvedAnimation(
                parent: _enter,
                curve: const Interval(0.545, 0.772, curve: Curves.easeOut),
              ),
              builder: (_, __) {
                final t = CurvedAnimation(
                  parent: _enter,
                  curve: const Interval(0.545, 0.772, curve: Curves.easeOut),
                ).value;
                return Container(
                  width: 120 * t,
                  height: 2,
                  decoration: BoxDecoration(
                    color: _orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // ── Arabic subtitle ───────────────────────────────────────
            AnimatedBuilder(
              animation: CurvedAnimation(
                parent: _enter,
                curve: const Interval(0.682, 0.9, curve: Curves.easeOut),
              ),
              builder: (_, __) {
                final t = CurvedAnimation(
                  parent: _enter,
                  curve: const Interval(0.682, 0.9, curve: Curves.easeOut),
                ).value;
                return Transform.translate(
                  offset: Offset(0, (1 - t) * 5),
                  child: Opacity(
                    opacity: t,
                    child: const Text(
                      'لياقة',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 4,
                        color: Color(0xFF6B5E57),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ── Dashed spinning hexagon rings ─────────────────────────────────────────────
class _HexRingPainter extends CustomPainter {
  final double rotation;
  _HexRingPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);
    canvas.translate(-cx, -cy);

    // Outer ring — dasharray 10 5, full opacity
    _drawDashedHex(canvas, size, 55, 8, 98, 31, 98, 79, 55, 102, 12, 79, 12, 31,
        strokeWidth: 2, color: const Color(0xFFD97757), dashLen: 10, gapLen: 5);

    canvas.restore();

    // Inner ring — dasharray 5 10, reverse (negative rotation), 40% opacity
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-rotation * (3 / 1.8)); // reverse + different speed
    canvas.translate(-cx, -cy);

    _drawDashedHex(canvas, size, 55, 18, 89, 37, 89, 73, 55, 92, 21, 73, 21, 37,
        strokeWidth: 1,
        color: const Color(0xFFD97757).withValues(alpha: 0.4),
        dashLen: 5,
        gapLen: 10);

    canvas.restore();
  }

  void _drawDashedHex(Canvas canvas, Size size,
      double x1, double y1, double x2, double y2,
      double x3, double y3, double x4, double y4,
      double x5, double y5, double x6, double y6,
      {required double strokeWidth,
      required Color color,
      required double dashLen,
      required double gapLen}) {
    final path = Path()
      ..moveTo(x1, y1)
      ..lineTo(x2, y2)
      ..lineTo(x3, y3)
      ..lineTo(x4, y4)
      ..lineTo(x5, y5)
      ..lineTo(x6, y6)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    _drawDashed(canvas, path, paint, dashLen, gapLen);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint, double dashLen, double gapLen) {
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      bool drawing = true;
      while (dist < metric.length) {
        final len = drawing ? dashLen : gapLen;
        if (drawing) {
          final extracted = metric.extractPath(dist, dist + len);
          canvas.drawPath(extracted, paint);
        }
        dist += len;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(_HexRingPainter old) => old.rotation != rotation;
}
