import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/support/my_support_tickets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  static const routeName = '/ContactUsScreen';
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.contactUsTitle,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryColor1, AppColors.primaryColor2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.headset_mic_outlined,
                      color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(l10n.contactUsTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Open a support ticket (tracked, with replies).
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MySupportTicketsScreen())),
                icon: const Icon(Icons.confirmation_number_outlined),
                label: Text(l10n.submitSupportTicket),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor1,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ContactTile(
              icon: Icons.email_outlined,
              label: l10n.contactEmail,
              value: 'youssef.fcaih@gmail.com',
              onTap: () => _copy(context, 'youssef.fcaih@gmail.com'),
            ),
            _ContactTile(
              icon: Icons.phone_outlined,
              label: l10n.contactPhone,
              value: '+20 122 939 1155',
              onTap: () => _openUrl('tel:+201229391155'),
            ),
            _ContactTile(
              icon: Icons.chat_outlined,
              label: l10n.contactWhatsApp,
              value: '+20 122 939 1155',
              onTap: () => _openUrl('https://wa.me/201229391155'),
            ),
            const SizedBox(height: 12),
            // Social links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  color: const Color(0xFF1877F2),
                  onTap: () => _openUrl(
                      'https://www.facebook.com/share/1D27MGwUzS/?mibextid=wwXIfr'),
                  child: const _BrandIcon(path: _kFacebookPath, size: 24),
                ),
                const SizedBox(width: 18),
                _SocialButton(
                  color: const Color(0xFFE4405F),
                  onTap: () => _openUrl(
                      'https://www.instagram.com/youssefghonem__?igsh=cWI4NWdhaGdxYTln&utm_source=qr'),
                  child: const _BrandIcon(path: _kInstagramPath, size: 24),
                ),
                const SizedBox(width: 18),
                _SocialButton(
                  color: const Color(0xFF0A66C2),
                  onTap: () => _openUrl(
                      'https://www.linkedin.com/in/youssef-ghonem-37213216a/'),
                  child: const _BrandIcon(path: _kLinkedInPath, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// Official simple-icons SVG path data (24×24 viewBox), rendered white.
const String _kFacebookPath =
    'M9.101 23.691v-7.98H6.627v-3.667h2.474v-1.58c0-4.085 1.848-5.978 5.858-5.978.401 0 .955.042 1.468.103a8.68 8.68 0 0 1 1.141.195v3.325a8.623 8.623 0 0 0-.653-.036 26.805 26.805 0 0 0-.733-.009c-.707 0-1.259.096-1.675.309a1.686 1.686 0 0 0-.679.622c-.258.42-.374.995-.374 1.752v1.297h3.919l-.386 2.103-.287 1.564h-3.246v8.245C19.396 23.238 24 18.179 24 12.044c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.628 3.874 10.35 9.101 11.647Z';
const String _kInstagramPath =
    'M12 0C8.74 0 8.333.015 7.053.072 5.775.132 4.905.333 4.14.63c-.789.306-1.459.717-2.126 1.384S.935 3.35.63 4.14C.333 4.905.131 5.775.072 7.053.012 8.333 0 8.74 0 12s.015 3.667.072 4.947c.06 1.277.261 2.148.558 2.913.306.788.717 1.459 1.384 2.126.667.666 1.336 1.079 2.126 1.384.766.296 1.636.499 2.913.558C8.333 23.988 8.74 24 12 24s3.667-.015 4.947-.072c1.277-.06 2.148-.262 2.913-.558.788-.306 1.459-.718 2.126-1.384.666-.667 1.079-1.335 1.384-2.126.296-.765.499-1.636.558-2.913.06-1.28.072-1.687.072-4.947s-.015-3.667-.072-4.947c-.06-1.277-.262-2.149-.558-2.913-.306-.789-.718-1.459-1.384-2.126C21.319 1.347 20.651.935 19.86.63c-.765-.297-1.636-.499-2.913-.558C15.667.012 15.26 0 12 0Zm0 2.16c3.203 0 3.585.016 4.85.071 1.17.055 1.805.249 2.227.415.562.217.96.477 1.382.896.419.42.679.819.896 1.381.164.422.36 1.057.413 2.227.057 1.266.07 1.646.07 4.85s-.015 3.585-.074 4.85c-.061 1.17-.256 1.805-.421 2.227a3.81 3.81 0 0 1-.899 1.382 3.744 3.744 0 0 1-1.38.896c-.42.164-1.065.36-2.235.413-1.274.057-1.649.07-4.859.07-3.211 0-3.586-.015-4.859-.074-1.171-.061-1.816-.256-2.236-.421a3.716 3.716 0 0 1-1.379-.899 3.644 3.644 0 0 1-.9-1.38c-.165-.42-.359-1.065-.42-2.235-.045-1.26-.061-1.649-.061-4.844 0-3.196.016-3.586.061-4.861.061-1.17.255-1.814.42-2.234.21-.57.479-.96.9-1.381.419-.419.81-.689 1.379-.898.42-.166 1.051-.361 2.221-.421 1.275-.045 1.65-.06 4.859-.06l.045.03Zm0 3.678a6.162 6.162 0 1 0 0 12.324 6.162 6.162 0 0 0 0-12.324ZM12 16a4 4 0 1 1 0-8 4 4 0 0 1 0 8Zm7.846-10.405a1.441 1.441 0 0 1-2.88 0 1.44 1.44 0 0 1 2.88 0Z';
const String _kLinkedInPath =
    'M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 0 1-2.063-2.065 2.064 2.064 0 1 1 2.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z';

class _BrandIcon extends StatelessWidget {
  final String path;
  final double size;
  const _BrandIcon({required this.path, required this.size});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '<path fill="white" d="$path"/></svg>',
      width: size,
      height: size,
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback onTap;
  const _SocialButton(
      {required this.child, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: child,
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _ContactTile(
      {required this.icon,
      required this.label,
      required this.value,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.listTile,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryColor1.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryColor1, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12, color: colors.subFg)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.fg)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.copy_outlined,
                  size: 16, color: colors.subFg),
          ],
        ),
      ),
    );
  }
}
