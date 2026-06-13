import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';

/// Gradient header used at the top of every platform screen.
class PlatformGradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget>? trailing;
  final bool showBack;
  const PlatformGradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryG,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor1.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13)),
              ],
            ),
          ),
          if (trailing != null) ...trailing!,
        ],
      ),
    );
  }
}

class PlatformCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const PlatformCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: card,
    );
  }
}

class PlatformKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? footer;
  const PlatformKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PlatformCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: colors.subFg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          if (footer != null) ...[
            const SizedBox(height: 2),
            Text(footer!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.mutedFg, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}

class PlatformSectionTitle extends StatelessWidget {
  final String title;
  const PlatformSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
            color: context.colors.fg,
            fontSize: 17,
            fontWeight: FontWeight.w700));
  }
}

class PlatformStatusChip extends StatelessWidget {
  final bool active;
  const PlatformStatusChip({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.successColor : AppColors.errorColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(active ? 'Active' : 'Inactive',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class PlatformEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const PlatformEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 54, color: colors.mutedFg),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.subFg, fontSize: 14)),
        ],
      ),
    );
  }
}

class PlatformErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const PlatformErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 54, color: colors.mutedFg),
          const SizedBox(height: 12),
          Text('Something went wrong',
              style: TextStyle(
                  color: colors.fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.subFg, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 44)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class PlatformSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  const PlatformSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: colors.fg),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.search_rounded, color: colors.subFg),
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

String platformMoney(double v, String currency) =>
    '${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)} $currency';
