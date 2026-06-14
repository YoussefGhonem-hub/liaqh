import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders the LIAQH brand mark (the hybrid logo SVG) at any size.
/// [bgColor]/[avatarColor] are kept for API compatibility but the SVG carries
/// its own brand colors.
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
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/images/liaqh_logo_hybrid.svg',
        width: size,
        height: size,
      );
}

