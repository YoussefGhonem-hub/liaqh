import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';

class TitleSubtitleCell extends StatelessWidget {
  final String title;
  final String subtitle;
  const TitleSubtitleCell({Key? key, required this.title, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 2)]),
      child: Column(
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                  colors: AppColors.primaryG,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight)
                  .createShader(
                  Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            child: Text(
              title,
              style: TextStyle(
                  color: AppColors.whiteColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: colors.subFg,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
