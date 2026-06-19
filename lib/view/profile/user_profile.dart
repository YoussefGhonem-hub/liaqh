import 'dart:io';

import 'package:fitnessapp/data/services/notification_service.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/profile/contact_us_screen.dart';
import 'package:fitnessapp/view/profile/personal_data_screen.dart';
import 'package:fitnessapp/view/profile/privacy_policy_screen.dart';
import 'package:fitnessapp/view/profile/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/language_toggle.dart';
import '../../common_widgets/user_avatar.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _notifications = NotificationService.popupEnabled;

  @override
  void initState() {
    super.initState();
    // Reflect the persisted preference.
    NotificationService.loadPopupPref().then((_) {
      if (mounted) setState(() => _notifications = NotificationService.popupEnabled);
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _LogoutDialog(),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.routeName, (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(l10n.profile,
            style: TextStyle(
                color: colors.fg, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: LanguageToggle(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 80),
        child: Column(
          children: [
            // ── Hero header card ────────────────────────────────────
            _HeroCard(user: user, l10n: l10n, colors: colors),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ── Account section ────────────────────────────────
                  _Section(
                    title: l10n.account,
                    icon: Icons.manage_accounts_rounded,
                    colors: colors,
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF6C63FF),
                        title: l10n.personalData,
                        onTap: () => Navigator.pushNamed(
                            context, PersonalDataScreen.routeName),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Notifications section ──────────────────────────
                  _Section(
                    title: l10n.notification,
                    icon: Icons.notifications_outlined,
                    colors: colors,
                    items: [
                      _ToggleMenuItem(
                        icon: Icons.notifications_active_rounded,
                        iconColor: Colors.orange,
                        title: l10n.popupNotification,
                        value: _notifications,
                        colors: colors,
                        onChanged: (v) {
                          setState(() => _notifications = v);
                          NotificationService.setPopupEnabled(v);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Other section ──────────────────────────────────
                  _Section(
                    title: l10n.other,
                    icon: Icons.more_horiz_rounded,
                    colors: colors,
                    items: [
                      _MenuItem(
                        icon: Icons.headset_mic_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        title: l10n.contactUs,
                        onTap: () => Navigator.pushNamed(
                            context, ContactUsScreen.routeName),
                      ),
                      _MenuItem(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        title: l10n.privacyPolicy,
                        onTap: () => Navigator.pushNamed(
                            context, PrivacyPolicyScreen.routeName),
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        iconColor: colors.subFg,
                        title: l10n.setting,
                        onTap: () => Navigator.pushNamed(
                            context, SettingsScreen.routeName),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Logout button ──────────────────────────────────
                  _LogoutButton(onTap: _logout, l10n: l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero header card ──────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final dynamic user;
  final AppLocalizations l10n;
  final AppThemeColors colors;
  const _HeroCard(
      {required this.user, required this.l10n, required this.colors});

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? '';
    final role = user?.role ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor1,
            AppColors.primaryColor2.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor1.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with ring — tap to change profile image
          GestureDetector(
            onTap: () => _changeProfileImage(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6), width: 2),
                  ),
                  child: UserAvatar(
                    imageUrl: user?.profileImageUrl,
                    name: name,
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primaryColor1, width: 1.5),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 14, color: AppColors.primaryColor1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(role,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Edit button
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, PersonalDataScreen.routeName),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeProfileImage(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 90,
    );
    if (picked == null) return;

    messenger.showSnackBar(SnackBar(
        content: Text(l10n.uploadingImage),
        duration: const Duration(seconds: 1)));
    final ok = await auth.uploadProfileImage(File(picked.path));
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? l10n.profileImageUpdated : l10n.uploadFailed),
      duration: const Duration(seconds: 2),
    ));
  }
}

// ── Section card ──────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppThemeColors colors;
  final List<Widget> items;
  const _Section({
    required this.title,
    required this.icon,
    required this.colors,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: colors.shadow, blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primaryColor1),
                const SizedBox(width: 6),
                Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.subFg,
                        letterSpacing: 0.6)),
              ],
            ),
          ),
          Divider(height: 1, color: colors.divider, indent: 16, endIndent: 16),
          ...items,
        ],
      ),
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        color: colors.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: colors.mutedFg),
          ],
        ),
      ),
    );
  }
}

// ── Toggle menu item ──────────────────────────────────────────────────────────
class _ToggleMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final AppThemeColors colors;
  final ValueChanged<bool> onChanged;
  const _ToggleMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w500))),
          _Toggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ── Custom toggle ─────────────────────────────────────────────────────────────
class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 46,
        height: 26,
        decoration: BoxDecoration(
          color: value
              ? AppColors.primaryColor1.withValues(alpha: 0.85)
              : const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Creative logout button ────────────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;
  final AppLocalizations l10n;
  const _LogoutButton({required this.onTap, required this.l10n});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) {
          _ctrl.forward();
          setState(() => _pressed = true);
        },
        onTapUp: (_) {
          _ctrl.reverse();
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () {
          _ctrl.reverse();
          setState(() => _pressed = false);
        },
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFEF4444),
                Color(0xFFDC2626),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444)
                    .withValues(alpha: _pressed ? 0.2 : 0.4),
                blurRadius: _pressed ? 8 : 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(widget.l10n.logout,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.3)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white54, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logout confirmation dialog ────────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Color(0xFFEF4444), size: 30),
            ),
            const SizedBox(height: 16),
            Text(l10n.logOutTitle,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.fg)),
            const SizedBox(height: 8),
            Text(l10n.logOutMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.subFg)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.divider),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(l10n.cancel,
                        style: TextStyle(
                            color: colors.subFg, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: Text(l10n.logOut,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
