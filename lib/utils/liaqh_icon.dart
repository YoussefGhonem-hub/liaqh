import 'package:flutter/material.dart';

/// Renders the LIAQH muscular-avatar hexagon icon at any size.
/// Matches the canvas drawing in liaqh_logo_all_sizes.html exactly.
class LiaqhIcon extends StatelessWidget {
  final double size;
  final Color bgColor;
  final Color avatarColor;

  const LiaqhIcon({
    super.key,
    this.size = 48,
    this.bgColor = const Color(0xFFD97757),
    this.avatarColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _LiaqhPainter(bgColor: bgColor, avatarColor: avatarColor),
        ),
      );
}

class _LiaqhPainter extends CustomPainter {
  final Color bgColor;
  final Color avatarColor;
  const _LiaqhPainter({required this.bgColor, required this.avatarColor});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 160.0;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    // ── Hexagon background ──────────────────────────────────────
    final hexPts = [
      [0.0, -80.0], [69.0, -40.0], [69.0, 40.0],
      [0.0, 80.0], [-69.0, 40.0], [-69.0, -40.0],
    ];
    final hexPath = _hexPath(hexPts, s, 1.0);
    canvas.drawPath(hexPath, Paint()..color = bgColor);

    // Glow ring
    canvas.drawPath(
      _hexPath(hexPts, s, 1.12),
      Paint()
        ..color = bgColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * s,
    );

    final fill = Paint()..color = avatarColor;

    // ── Head ──────────────────────────────────────────────────────
    canvas.drawCircle(Offset(0, -52 * s), 13 * s, fill);

    // ── Neck ──────────────────────────────────────────────────────
    canvas.drawRect(Rect.fromLTWH(-6 * s, -40 * s, 12 * s, 9 * s), fill);

    // ── Traps ─────────────────────────────────────────────────────
    _drawPath(canvas, fill, (p) {
      p.moveTo(-18 * s, -33 * s);
      p.quadraticBezierTo(-10 * s, -39 * s, 0, -40 * s);
      p.quadraticBezierTo(10 * s, -39 * s, 18 * s, -33 * s);
      p.lineTo(22 * s, -21 * s);
      p.quadraticBezierTo(10 * s, -27 * s, 0, -28 * s);
      p.quadraticBezierTo(-10 * s, -27 * s, -22 * s, -21 * s);
      p.close();
    });

    // ── Shoulders ─────────────────────────────────────────────────
    canvas.drawOval(
        Rect.fromCenter(center: Offset(-26 * s, -20 * s), width: 26 * s, height: 22 * s), fill);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(26 * s, -20 * s), width: 26 * s, height: 22 * s), fill);

    // ── Chest ─────────────────────────────────────────────────────
    _drawPath(canvas, fill, (p) {
      p.moveTo(-18 * s, -28 * s);
      p.quadraticBezierTo(-10 * s, -33 * s, 0, -32 * s);
      p.quadraticBezierTo(10 * s, -33 * s, 18 * s, -28 * s);
      p.lineTo(20 * s, -5 * s);
      p.quadraticBezierTo(10 * s, 1 * s, 0, 0);
      p.quadraticBezierTo(-10 * s, 1 * s, -20 * s, -5 * s);
      p.close();
    });

    // ── Left upper arm ────────────────────────────────────────────
    _drawPath(canvas, fill, (p) {
      p.moveTo(-28 * s, -30 * s);
      p.quadraticBezierTo(-40 * s, -25 * s, -42 * s, -10 * s);
      p.quadraticBezierTo(-40 * s, 2 * s, -32 * s, 5 * s);
      p.lineTo(-26 * s, -5 * s);
      p.quadraticBezierTo(-30 * s, -15 * s, -28 * s, -22 * s);
      p.close();
    });

    // ── Right upper arm ───────────────────────────────────────────
    _drawPath(canvas, fill, (p) {
      p.moveTo(28 * s, -30 * s);
      p.quadraticBezierTo(40 * s, -25 * s, 42 * s, -10 * s);
      p.quadraticBezierTo(40 * s, 2 * s, 32 * s, 5 * s);
      p.lineTo(26 * s, -5 * s);
      p.quadraticBezierTo(30 * s, -15 * s, 28 * s, -22 * s);
      p.close();
    });

    // ── Left forearm ──────────────────────────────────────────────
    _drawPath(canvas, fill, (p) {
      p.moveTo(-32 * s, 5 * s);
      p.quadraticBezierTo(-38 * s, 14 * s, -36 * s, 24 * s);
      p.lineTo(-28 * s, 24 * s);
      p.quadraticBezierTo(-28 * s, 14 * s, -26 * s, 5 * s);
      p.close();
    });

    // ── Right forearm ─────────────────────────────────────────────
    _drawPath(canvas, fill, (p) {
      p.moveTo(32 * s, 5 * s);
      p.quadraticBezierTo(38 * s, 14 * s, 36 * s, 24 * s);
      p.lineTo(28 * s, 24 * s);
      p.quadraticBezierTo(28 * s, 14 * s, 26 * s, 5 * s);
      p.close();
    });

    // ── Fists ─────────────────────────────────────────────────────
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-44 * s, 22 * s, 16 * s, 12 * s), Radius.circular(4 * s)), fill);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(28 * s, 22 * s, 16 * s, 12 * s), Radius.circular(4 * s)), fill);

    // ── Abs (6-pack) ──────────────────────────────────────────────
    for (final pair in [
      [-14.0, -1.0], [0.0, -1.0], [14.0, -1.0],
      [-14.0, 11.0], [0.0, 11.0], [14.0, 11.0],
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((pair[0] - 6) * s, (pair[1] - 2) * s, 11 * s, 11 * s),
          Radius.circular(2 * s),
        ),
        Paint()..color = avatarColor.withValues(alpha: 0.82),
      );
    }

    // ── Obliques ──────────────────────────────────────────────────
    _drawPath(canvas, fill, (p) {
      p.moveTo(-15 * s, 22 * s);
      p.quadraticBezierTo(-20 * s, 28 * s, -18 * s, 36 * s);
      p.lineTo(-12 * s, 36 * s);
      p.quadraticBezierTo(-12 * s, 28 * s, -10 * s, 22 * s);
      p.close();
    });
    _drawPath(canvas, fill, (p) {
      p.moveTo(15 * s, 22 * s);
      p.quadraticBezierTo(20 * s, 28 * s, 18 * s, 36 * s);
      p.lineTo(12 * s, 36 * s);
      p.quadraticBezierTo(12 * s, 28 * s, 10 * s, 22 * s);
      p.close();
    });

    // ── Quads ─────────────────────────────────────────────────────
    _drawPath(canvas, fill, (p) {
      p.moveTo(-18 * s, 34 * s);
      p.quadraticBezierTo(-24 * s, 42 * s, -22 * s, 58 * s);
      p.lineTo(-12 * s, 60 * s);
      p.quadraticBezierTo(-10 * s, 44 * s, -10 * s, 34 * s);
      p.close();
    });
    _drawPath(canvas, fill, (p) {
      p.moveTo(18 * s, 34 * s);
      p.quadraticBezierTo(24 * s, 42 * s, 22 * s, 58 * s);
      p.lineTo(12 * s, 60 * s);
      p.quadraticBezierTo(10 * s, 44 * s, 10 * s, 34 * s);
      p.close();
    });

    // ── Inner legs ────────────────────────────────────────────────
    _drawPath(canvas, Paint()..color = avatarColor.withValues(alpha: 0.85), (p) {
      p.moveTo(-8 * s, 34 * s);
      p.quadraticBezierTo(-4 * s, 42 * s, -2 * s, 60 * s);
      p.lineTo(2 * s, 60 * s);
      p.quadraticBezierTo(4 * s, 42 * s, 8 * s, 34 * s);
      p.close();
    });

    // ── Flame (top right) ─────────────────────────────────────────
    _drawPath(canvas, Paint()..color = avatarColor.withValues(alpha: 0.8), (p) {
      p.moveTo(55 * s, -62 * s);
      p.cubicTo(55 * s, -70 * s, 63 * s, -74 * s, 61 * s, -82 * s);
      p.cubicTo(67 * s, -77 * s, 69 * s, -68 * s, 64 * s, -62 * s);
      p.cubicTo(62 * s, -58 * s, 56 * s, -58 * s, 55 * s, -62 * s);
      p.close();
    });

    // ── Energy lines ──────────────────────────────────────────────
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round;

    for (final coords in [
      [-78.0, -45.0, -64.0, -38.0],
      [-82.0, -20.0, -66.0, -18.0],
      [-78.0, 8.0, -64.0, 4.0],
    ]) {
      canvas.drawLine(
        Offset(coords[0] * s, coords[1] * s),
        Offset(coords[2] * s, coords[3] * s),
        linePaint,
      );
    }
    for (final coords in [
      [78.0, -45.0, 64.0, -38.0],
      [82.0, -20.0, 66.0, -18.0],
      [78.0, 8.0, 64.0, 4.0],
    ]) {
      canvas.drawLine(
        Offset(coords[0] * s, coords[1] * s),
        Offset(coords[2] * s, coords[3] * s),
        linePaint,
      );
    }

    canvas.restore();
  }

  Path _hexPath(List<List<double>> pts, double s, double scale) {
    final p = Path();
    p.moveTo(pts[0][0] * s * scale, pts[0][1] * s * scale);
    for (int i = 1; i < pts.length; i++) {
      p.lineTo(pts[i][0] * s * scale, pts[i][1] * s * scale);
    }
    p.close();
    return p;
  }

  void _drawPath(Canvas canvas, Paint paint, void Function(Path) build) {
    final p = Path();
    build(p);
    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant _LiaqhPainter old) =>
      old.bgColor != bgColor || old.avatarColor != avatarColor;
}
