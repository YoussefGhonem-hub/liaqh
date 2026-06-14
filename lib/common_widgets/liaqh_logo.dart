import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The LIAQH brand mark (the hybrid logo).
class FlameLogo extends StatelessWidget {
  final double size;
  const FlameLogo({super.key, this.size = 48});

  static const asset = 'assets/images/liaqh_logo_hybrid.svg';

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset(asset, width: size, height: size);
}

/// Flame + "LIAQH" wordmark (the "A" is tinted), used on Welcome / Login headers.
class LiaqhWordmark extends StatelessWidget {
  final double flameSize;
  final double fontSize;
  const LiaqhWordmark({super.key, this.flameSize = 28, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlameLogo(size: flameSize),
        const SizedBox(width: 8),
        Text('LIAQH',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              color: const Color(0xFFFAF6F2),
            )),
      ],
    );
  }
}
