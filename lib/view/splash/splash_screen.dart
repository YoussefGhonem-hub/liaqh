import 'dart:math' as math;
import 'package:fitnessapp/common_widgets/liaqh_logo.dart';
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
  late final AnimationController _spin;
  late final AnimationController _pulse;
  late final AnimationController _enter;

  static const _orange = Color(0xFFD97757);
  static const _bg = Color(0xFF1C1714);
  static const _letters = ['L', 'I', 'A', 'Q', 'H'];

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..forward();

    // Always show the splash for 3 seconds, then route (Dashboard if logged in).
    Future.wait([
      widget.onCheck(),
      Future.delayed(const Duration(seconds: 3)),
    ]).then((r) {
      if (mounted) widget.onDone(r[0] as bool);
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Radial glow
            Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Color(0x2ED97757),
                  Color(0x00D97757),
                ]),
              ),
            ),

            Center(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hexagon dot spinner + flame
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _spin,
                        builder: (_, __) => Transform.rotate(
                          angle: _spin.value * 2 * math.pi,
                          child: CustomPaint(
                            size: const Size(120, 120),
                            painter: _HexDotsPainter(),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, __) => Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _orange.withValues(
                                alpha: 0.18 + 0.18 * _pulse.value),
                          ),
                        ),
                      ),
                      const FlameLogo(size: 44),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // LIAQH wordmark
                FadeTransition(
                  opacity: _enter,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_letters.length, (i) {
                      return Text(
                        _letters[i],
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          color: _letters[i] == 'A'
                              ? _orange
                              : const Color(0xFFFAF6F2),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _enter,
                  child: const Text(
                    'لياقة • FITNESS',
                    style: TextStyle(
                        color: Color(0xFF6B5E57),
                        fontSize: 13,
                        letterSpacing: 2),
                  ),
                ),
              ],
            ),
            ),

            // Loading dots
            Positioned(
              bottom: 72,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final phase = (_pulse.value + i * 0.33) % 1.0;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _orange.withValues(alpha: 0.3 + 0.7 * phase),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Six dots + faint hexagon outline arranged around a circle.
class _HexDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const r = 54.0;

    // Hexagon outline
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFD97757).withValues(alpha: 0.3);
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (-90 + i * 60) * math.pi / 180;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, outline);

    // Dots
    for (int i = 0; i < 6; i++) {
      final a = (-90 + i * 60) * math.pi / 180;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      final dot = Paint()
        ..color = const Color(0xFFD97757).withValues(alpha: 0.5 + i * 0.08);
      canvas.drawCircle(p, 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(_HexDotsPainter old) => false;
}
