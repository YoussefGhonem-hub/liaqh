import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// The shared button from the design system. A solid orange primary, a tinted
/// outline secondary, and a subtle tap-scale press. Use everywhere for a
/// consistent, modern look.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool loading;
  final IconData? icon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.loading = false,
    this.icon,
    this.height = 54,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final secondary = widget.secondary;
    final fg = secondary ? AppColors.primaryColor1 : Colors.white;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.5,
          duration: const Duration(milliseconds: 150),
          child: Container(
            height: widget.height,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: secondary
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.primaryColor1, AppColors.primaryColor2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: secondary
                  ? AppColors.primaryColor1.withValues(alpha: 0.12)
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: secondary
                  ? Border.all(
                      color: AppColors.primaryColor1.withValues(alpha: 0.4),
                      width: 1.5)
                  : null,
              boxShadow: secondary
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primaryColor1.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: widget.loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: fg),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fg, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(widget.label,
                          style: TextStyle(
                              color: fg,
                              fontSize: 16,
                              fontWeight:
                                  secondary ? FontWeight.w600 : FontWeight.w700)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
