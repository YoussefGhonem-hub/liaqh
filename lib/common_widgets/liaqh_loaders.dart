// LIAQH LOADERS — built around the original HYBRID logo mark + the LIAQH word.
// Pure Flutter, no external packages. Drop this file in lib/ and use any widget,
// e.g.  const Center(child: LiaqhHybridLoader())
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fitnessapp/common_widgets/liaqh_logo.dart';

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

// ─────────────────────────────────────────────────────────────
// LIAQH MARK LOADER — the brand splash spinner: a rotating hexagon of
// dots around a pulsing glow + the flame logo. Use anywhere you'd
// normally put a CircularProgressIndicator.
//   const Center(child: LiaqhMarkLoader())
// ─────────────────────────────────────────────────────────────
class LiaqhMarkLoader extends StatefulWidget {
  final double size;
  const LiaqhMarkLoader({super.key, this.size = 56});

  @override
  State<LiaqhMarkLoader> createState() => _LiaqhMarkLoaderState();
}

class _LiaqhMarkLoaderState extends State<LiaqhMarkLoader>
    with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
      vsync: this, duration: const Duration(seconds: 3))
    ..repeat();
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _spin,
            builder: (_, __) => Transform.rotate(
              angle: _spin.value * 2 * math.pi,
              child: CustomPaint(
                size: Size.square(s),
                painter: const HexDotsPainter(),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: s * 0.53,
              height: s * 0.53,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kLiaqhTerra
                    .withValues(alpha: 0.18 + 0.18 * _pulse.value),
              ),
            ),
          ),
          FlameLogo(size: s * 0.37),
        ],
      ),
    );
  }
}

/// Six dots + faint hexagon outline arranged around a circle (brand spinner).
class HexDotsPainter extends CustomPainter {
  const HexDotsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.45;

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.0125
      ..color = kLiaqhTerra.withValues(alpha: 0.3);
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (-90 + i * 60) * math.pi / 180;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, outline);

    for (int i = 0; i < 6; i++) {
      final a = (-90 + i * 60) * math.pi / 180;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      final dot = Paint()..color = kLiaqhTerra.withValues(alpha: 0.5 + i * 0.08);
      canvas.drawCircle(p, size.width * 0.029, dot);
    }
  }

  @override
  bool shouldRepaint(HexDotsPainter old) => false;
}

/// Full-screen brand loader: the spinner + animated "LIAQH" wordmark and
/// subtitle. Drop-in replacement for a page-level `CircularProgressIndicator`.
class LiaqhPageLoader extends StatefulWidget {
  final double size;

  /// Set false to show only the spinner (e.g. small pagination footers).
  final bool showWordmark;
  const LiaqhPageLoader({super.key, this.size = 104, this.showWordmark = true});

  @override
  State<LiaqhPageLoader> createState() => _LiaqhPageLoaderState();
}

class _LiaqhPageLoaderState extends State<LiaqhPageLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);

  static const _letters = ['L', 'I', 'A', 'Q', 'H'];

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).textTheme.titleLarge?.color ??
        const Color(0xFFFAF6F2);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Soft radial glow behind the spinner.
          Container(
            width: widget.size * 1.7,
            height: widget.size * 1.7,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Color(0x22D97757),
                Color(0x00D97757),
              ]),
            ),
            child: LiaqhMarkLoader(size: widget.size),
          ),
          if (widget.showWordmark) ...[
            const SizedBox(height: 14),
            FadeTransition(
              opacity: Tween(begin: 0.55, end: 1.0).animate(_breathe),
              child: isArabic
                  ? Text(
                      'لياقة',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_letters.length, (i) {
                        return Text(
                          _letters[i],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                            color: _letters[i] == 'A' ? kLiaqhTerra : fg,
                          ),
                        );
                      }),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              isArabic ? 'لياقة • للياقة البدنية' : 'لياقة • FITNESS',
              style: const TextStyle(
                  color: Color(0xFF8A7A70),
                  fontSize: 11,
                  letterSpacing: 2),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LIAQH LOADING OVERLAY — a transparent, blurred full-screen loader.
// Use during navigation / async work:
//   await LiaqhLoading.during(context, () => doWork());
//   // or manually: LiaqhLoading.show(context); ... LiaqhLoading.hide(context);
// ─────────────────────────────────────────────────────────────
class LiaqhLoading {
  static bool _open = false;

  /// Shows a blurred, semi-transparent overlay with the LIAQH loader.
  static void show(BuildContext context) {
    if (_open) return;
    _open = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      useRootNavigator: true,
      builder: (_) => const _LiaqhLoadingOverlay(),
    );
  }

  /// Hides the overlay if showing.
  static void hide(BuildContext context) {
    if (!_open) return;
    _open = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Runs [action] while showing the overlay; always hides afterwards.
  static Future<T> during<T>(
      BuildContext context, Future<T> Function() action) async {
    show(context);
    try {
      return await action();
    } finally {
      if (context.mounted) hide(context);
    }
  }
}

class _LiaqhLoadingOverlay extends StatelessWidget {
  const _LiaqhLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: const Center(child: LiaqhMarkLoader(size: 96)),
    );
  }
}
