import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/data/services/notification_service.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/language_provider.dart';
import 'package:fitnessapp/providers/theme_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/profile/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/SettingsScreen';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = NotificationService.popupEnabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = context.watch<LanguageProvider>();
    final theme = context.watch<ThemeProvider>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        title: Text(l10n.settingsTitle,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 18, color: colors.fg)),
        foregroundColor: colors.fg,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Account ──────────────────────────────────────────────────
          _SectionHeader(title: l10n.account, colors: colors),
          _Card(
            colors: colors,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  Navigator.pushNamed(context, ChangePasswordScreen.routeName),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    const _IconBubble(
                        icon: Icons.lock_outline_rounded,
                        color: AppColors.primaryColor1),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.changePassword,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colors.fg)),
                          Text(l10n.updateAccountPassword,
                              style:
                                  TextStyle(fontSize: 12, color: colors.subFg)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: colors.subFg),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Appearance ───────────────────────────────────────────────
          _SectionHeader(title: l10n.appearance, colors: colors),
          _Card(
            colors: colors,
            child: Column(
              children: [
                // Dark mode row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: [
                      _IconBubble(
                        icon: theme.isDark ? Icons.dark_mode : Icons.light_mode,
                        color: theme.isDark
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.darkMode,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: colors.fg)),
                            Text(theme.isDark ? l10n.settingOn : l10n.settingOff,
                                style: TextStyle(
                                    fontSize: 12, color: colors.subFg)),
                          ],
                        ),
                      ),
                      // Beautiful animated toggle
                      GestureDetector(
                        onTap: () => theme.toggle(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                          width: 56,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: theme.isDark
                                ? const LinearGradient(colors: [
                                    Color(0xFF7C3AED),
                                    Color(0xFF4F46E5)
                                  ])
                                : LinearGradient(
                                    colors: [colors.listTile, colors.listTile]),
                            border: Border.all(
                              color: theme.isDark
                                  ? Colors.transparent
                                  : colors.divider,
                            ),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeInOut,
                            alignment: theme.isDark
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.all(3),
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2))
                                ],
                              ),
                              child: Icon(
                                theme.isDark
                                    ? Icons.nightlight_round
                                    : Icons.wb_sunny_rounded,
                                size: 14,
                                color: theme.isDark
                                    ? const Color(0xFF7C3AED)
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: colors.divider, height: 1),
                // Language row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  child: Row(
                    children: [
                      const _IconBubble(
                          icon: Icons.language, color: AppColors.primaryColor1),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(l10n.language,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colors.fg)),
                      ),
                      _LangChip(
                        label: l10n.english,
                        selected: !lang.isArabic,
                        colors: colors,
                        onTap: () => lang.setLocale(const Locale('en')),
                      ),
                      const SizedBox(width: 8),
                      _LangChip(
                        label: l10n.arabic,
                        selected: lang.isArabic,
                        colors: colors,
                        onTap: () => lang.setLocale(const Locale('ar')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Notifications ─────────────────────────────────────────────
          _SectionHeader(title: l10n.notification, colors: colors),
          _Card(
            colors: colors,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  const _IconBubble(
                      icon: Icons.notifications_outlined, color: Colors.orange),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.pushNotifications,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colors.fg)),
                        Text(l10n.receiveWorkoutReminders,
                            style:
                                TextStyle(fontSize: 12, color: colors.subFg)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _pushNotifications,
                    onChanged: (v) {
                      setState(() => _pushNotifications = v);
                      NotificationService.setPopupEnabled(v);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── About ─────────────────────────────────────────────────────
          _SectionHeader(title: l10n.appVersion, colors: colors),
          _Card(
            colors: colors,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  _IconBubble(icon: Icons.info_outline, color: colors.subFg),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(l10n.appVersion,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.fg)),
                  ),
                  Text(l10n.version,
                      style: TextStyle(fontSize: 13, color: colors.subFg)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Danger Zone ───────────────────────────────────────────────
          _SectionHeader(title: l10n.dangerZone, colors: colors),
          _Card(
            colors: colors,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _confirmDelete(context, l10n),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    const _IconBubble(
                        icon: Icons.delete_forever_rounded,
                        color: AppColors.errorColor),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.deleteAccount,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.errorColor)),
                          Text(l10n.deleteAccountSubtitle,
                              style:
                                  TextStyle(fontSize: 12, color: colors.subFg)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: colors.subFg),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AppLocalizations l10n) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        title: Text(l10n.deleteAccountConfirmTitle,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
        content: Text(l10n.deleteAccountConfirmBody,
            style: TextStyle(color: colors.subFg)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: TextStyle(color: colors.subFg)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete,
                style: const TextStyle(
                    color: AppColors.errorColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final ok = await LiaqhLoading.during(context, () => auth.deleteAccount());

    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeleted)));
      navigator.pushNamedAndRemoveUntil(LoginScreen.routeName, (r) => false);
    } else {
      messenger.showSnackBar(SnackBar(
          content: Text(l10n.deleteAccountFailed),
          backgroundColor: AppColors.errorColor));
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppThemeColors colors;
  const _SectionHeader({required this.title, required this.colors});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.subFg,
                letterSpacing: 0.8)),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  final AppThemeColors colors;
  const _Card({required this.child, required this.colors});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBubble({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      );
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final AppThemeColors colors;
  final VoidCallback onTap;
  const _LangChip({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [AppColors.primaryColor1, AppColors.primaryColor2])
                : null,
            color: selected ? null : colors.listTile,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : colors.subFg)),
        ),
      );
}
