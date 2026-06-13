import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnessapp/data/services/api_service.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// A circular user avatar that shows the uploaded profile image when available
/// and falls back to the first letter of the name. Used across the sidebar,
/// chat, and profile screens so avatars stay consistent everywhere.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 24,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Builds an absolute URL from a stored relative path like
  /// `/uploads/profile-images/abc.jpg`. Returns null when there is nothing
  /// to show, so the caller falls back to initials.
  static String? resolveUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${ApiService.baseUrl.replaceAll('/api', '')}$path';
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final url = resolveUrl(imageUrl);
    final bg = backgroundColor ?? AppColors.primaryColor1.withValues(alpha: 0.15);
    final fg = foregroundColor ?? AppColors.primaryColor1;

    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(initial,
          style: TextStyle(
              color: fg,
              fontSize: radius * 0.72,
              fontWeight: FontWeight.w700)),
    );

    if (url == null) return fallback;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => fallback,
          errorWidget: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}
