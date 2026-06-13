import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const routeName = '/PrivacyPolicyScreen';
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    const sections = [
      _Section('1. Information We Collect',
          'We collect information you provide when creating an account, such as your name, email address, and fitness data. We also collect usage data to improve our services.'),
      _Section('2. How We Use Information',
          'Your data is used to personalise your experience, provide coaching insights, and improve the platform. We do not sell your personal information to third parties.'),
      _Section('3. Data Storage',
          'Your information is securely stored and protected using industry-standard encryption. We retain data only as long as necessary to provide our services.'),
      _Section('4. Sharing Information',
          'Your fitness data is shared only with your assigned coach within the platform. We do not share data with external parties without your explicit consent.'),
      _Section('5. Your Rights',
          'You have the right to access, correct, or delete your personal data at any time. Contact us through the app to exercise these rights.'),
      _Section('6. Changes to this Policy',
          'We may update this policy from time to time. We will notify you of significant changes through the app or via email.'),
      _Section('7. Contact',
          'For privacy-related questions, contact us at privacy@gymapp.com.'),
    ];

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.privacyPolicyTitle,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => _SectionCard(section: sections[i]),
      ),
    );
  }
}

class _Section {
  final String title;
  final String body;
  const _Section(this.title, this.body);
}

class _SectionCard extends StatelessWidget {
  final _Section section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: colors.fg)),
          const SizedBox(height: 8),
          Text(section.body,
              style: TextStyle(
                  fontSize: 13,
                  color: colors.subFg,
                  height: 1.5)),
        ],
      ),
    );
  }
}
