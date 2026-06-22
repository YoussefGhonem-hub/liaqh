import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/common_widgets/user_avatar.dart';
import 'package:fitnessapp/data/models/coach_profile_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/coach_profile_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';

/// Read-only screen for a trainee to view their coach's full public profile
/// and submit/update a rating + review.
class CoachProfileViewScreen extends StatefulWidget {
  final String coachUserId;
  const CoachProfileViewScreen({super.key, required this.coachUserId});

  static const routeName = '/CoachProfileViewScreen';

  @override
  State<CoachProfileViewScreen> createState() => _CoachProfileViewScreenState();
}

class _CoachProfileViewScreenState extends State<CoachProfileViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachProfileProvider>().load(widget.coachUserId);
    });
  }

  Future<void> _open(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  bool _isEssentiallyEmpty(CoachProfile p) =>
      (p.headline == null || p.headline!.trim().isEmpty) &&
      (p.bio == null || p.bio!.trim().isEmpty) &&
      p.specialtyTags.isEmpty &&
      p.certifications.isEmpty &&
      p.transformations.isEmpty &&
      p.files.isEmpty &&
      p.reviews.isEmpty &&
      p.traineesCoached == 0 &&
      p.transformationsCount == 0 &&
      p.reviewCount == 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: Text(l10n.coachProfile)),
      body: Consumer<CoachProfileProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.profile == null) {
            return const LiaqhPageLoader();
          }
          final profile = provider.profile;
          if (profile == null || _isEssentiallyEmpty(profile)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.coachProfileEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.subFg, fontSize: 15),
                ),
              ),
            );
          }
          return _Body(
            profile: profile,
            coachUserId: widget.coachUserId,
            onOpen: _open,
          );
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Body
class _Body extends StatelessWidget {
  final CoachProfile profile;
  final String coachUserId;
  final Future<void> Function(String? url) onOpen;
  const _Body({
    required this.profile,
    required this.coachUserId,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _Header(profile: profile),
        const SizedBox(height: 16),
        _StatsRow(profile: profile),
        if (profile.instagramUrl != null || profile.whatsappNumber != null) ...[
          const SizedBox(height: 16),
          _ContactRow(profile: profile, onOpen: onOpen),
        ],
        if ((profile.bio ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            title: l10n.coachProfile,
            child: Text(
              profile.bio!.trim(),
              style: TextStyle(color: context.colors.subFg, height: 1.5),
            ),
          ),
        ],
        if (profile.certifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Certifications(items: profile.certifications),
        ],
        if (profile.transformations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Transformations(items: profile.transformations),
        ],
        if (profile.files.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Documents(items: profile.files, onOpen: onOpen),
        ],
        const SizedBox(height: 16),
        _ReviewsSection(profile: profile, coachUserId: coachUserId),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────── Header
class _Header extends StatelessWidget {
  final CoachProfile profile;
  const _Header({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        UserAvatar(
          imageUrl: profile.profileImageUrl,
          name: profile.fullName,
          radius: 48,
        ),
        const SizedBox(height: 12),
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.fg,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        if ((profile.headline ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            profile.headline!.trim(),
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.subFg, fontSize: 14),
          ),
        ],
        if (profile.specialtyTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: profile.specialtyTags
                .map((t) => Chip(
                      label: Text(t),
                      backgroundColor: AppColors.primaryColor1.withValues(
                        alpha: 0.12,
                      ),
                      labelStyle: const TextStyle(
                        color: AppColors.primaryColor1,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      side: BorderSide.none,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────── Stats
class _StatsRow extends StatelessWidget {
  final CoachProfile profile;
  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pills = <Widget>[
      _StatPill(
        value: '${profile.traineesCoached}',
        label: l10n.statTrainees,
        icon: Icons.people_alt_outlined,
      ),
      _StatPill(
        value: '${profile.transformationsCount}',
        label: l10n.statTransformations,
        icon: Icons.auto_awesome_outlined,
      ),
      if (profile.yearsOfExperience != null)
        _StatPill(
          value: '${profile.yearsOfExperience}',
          label: l10n.statYears,
          icon: Icons.workspace_premium_outlined,
        ),
      _StatPill(
        value:
            '${profile.averageRating.toStringAsFixed(1)} (${profile.reviewCount})',
        label: l10n.statRating,
        icon: Icons.star_rounded,
      ),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: pills
          .map((p) => SizedBox(
                width: (MediaQuery.of(context).size.width - 32 - 10) / 2,
                child: p,
              ))
          .toList(),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatPill({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor1, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.subFg, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Contact
class _ContactRow extends StatelessWidget {
  final CoachProfile profile;
  final Future<void> Function(String? url) onOpen;
  const _ContactRow({required this.profile, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        if (profile.instagramUrl != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => onOpen(profile.instagramUrl),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: Text(l10n.instagramLabel),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 46),
                foregroundColor: AppColors.primaryColor1,
                side: const BorderSide(color: AppColors.primaryColor1),
              ),
            ),
          ),
        if (profile.instagramUrl != null && profile.whatsappNumber != null)
          const SizedBox(width: 10),
        if (profile.whatsappNumber != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final digits =
                    profile.whatsappNumber!.replaceAll(RegExp(r'[^0-9]'), '');
                onOpen('https://wa.me/$digits');
              },
              icon: const Icon(Icons.chat_outlined, size: 18),
              label: Text(l10n.messageOnWhatsapp),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successColor,
                minimumSize: const Size(0, 46),
              ),
            ),
          ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────── Section card
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.fg,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Full-screen image
class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({required this.url});

  static void open(BuildContext context, String? rawUrl) {
    final url = UserAvatar.resolveUrl(rawUrl);
    if (url == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _FullScreenImage(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Certifications
class _Certifications extends StatelessWidget {
  final List<CoachCertification> items;
  const _Certifications({required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return _SectionCard(
      title: l10n.certifications,
      child: Column(
        children: items.map((c) {
          final subtitle = [
            if ((c.issuer ?? '').isNotEmpty) c.issuer!,
            if (c.year != null) '${c.year}',
          ].join(' · ');
          final thumb = UserAvatar.resolveUrl(c.imageUrl);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thumb != null)
                  GestureDetector(
                    onTap: () => _FullScreenImage.open(context, c.imageUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        thumb,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 52,
                          height: 52,
                          color: colors.inputFill,
                          child: Icon(Icons.image_outlined,
                              color: colors.mutedFg),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.workspace_premium_outlined,
                        color: AppColors.primaryColor1),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title,
                        style: TextStyle(
                          color: colors.fg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style:
                              TextStyle(color: colors.subFg, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Transformations
class _Transformations extends StatelessWidget {
  final List<CoachTransformation> items;
  const _Transformations({required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return _SectionCard(
      title: l10n.transformationsTitle,
      child: SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final t = items[i];
            return SizedBox(
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _BeforeAfterImage(
                          label: l10n.beforeLabel,
                          rawUrl: t.beforeImageUrl,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _BeforeAfterImage(
                          label: l10n.afterLabel,
                          rawUrl: t.afterImageUrl,
                        ),
                      ),
                    ],
                  ),
                  if ((t.caption ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      t.caption!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.fg,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if ((t.durationText ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      t.durationText!,
                      style: TextStyle(color: colors.subFg, fontSize: 12),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BeforeAfterImage extends StatelessWidget {
  final String label;
  final String? rawUrl;
  const _BeforeAfterImage({required this.label, required this.rawUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = UserAvatar.resolveUrl(rawUrl);
    return GestureDetector(
      onTap: url == null
          ? null
          : () => _FullScreenImage.open(context, rawUrl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 0.85,
              child: url == null
                  ? Container(
                      color: colors.inputFill,
                      child: Icon(Icons.image_outlined,
                          color: colors.mutedFg),
                    )
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colors.inputFill,
                        child: Icon(Icons.broken_image_outlined,
                            color: colors.mutedFg),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: colors.subFg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Documents
class _Documents extends StatelessWidget {
  final List<CoachFile> items;
  final Future<void> Function(String? url) onOpen;
  const _Documents({required this.items, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return _SectionCard(
      title: l10n.documentsTitle,
      child: Column(
        children: items.map((f) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined,
                  color: AppColors.primaryColor1),
              title: Text(
                f.fileName,
                style: TextStyle(color: colors.fg, fontSize: 14),
              ),
              trailing: Icon(Icons.open_in_new, size: 18, color: colors.subFg),
              onTap: () => onOpen(UserAvatar.resolveUrl(f.url) ?? f.url),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Reviews
class _ReviewsSection extends StatefulWidget {
  final CoachProfile profile;
  final String coachUserId;
  const _ReviewsSection({required this.profile, required this.coachUserId});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  late int _rating;
  late final TextEditingController _commentCtrl;

  @override
  void initState() {
    super.initState();
    _rating = widget.profile.myRating ?? 0;
    _commentCtrl = TextEditingController(text: widget.profile.myReview ?? '');
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<CoachProfileProvider>();
    final ok = await provider.submitReview(
      coachUserId: widget.coachUserId,
      rating: _rating,
      comment: _commentCtrl.text.trim().isEmpty
          ? null
          : _commentCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reviewSubmitted)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final profile = widget.profile;
    final saving = context.watch<CoachProfileProvider>().saving;

    return _SectionCard(
      title: l10n.reviewsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.primaryColor1, size: 28),
              const SizedBox(width: 6),
              Text(
                profile.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  color: colors.fg,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${profile.reviewCount})',
                style: TextStyle(color: colors.subFg, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rate-your-coach card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.rateYourCoach,
                  style: TextStyle(
                    color: colors.fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _StarSelector(
                  rating: _rating,
                  onChanged: saving
                      ? null
                      : (v) => setState(() => _rating = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentCtrl,
                  enabled: !saving,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.writeReviewOptional,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_rating == 0 || saving) ? null : _submit,
                    child: saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.submitReview),
                  ),
                ),
              ],
            ),
          ),

          if ((profile.myReview ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.yourReview,
              style: TextStyle(
                color: colors.subFg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 16),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: 12),

          // Existing reviews
          if (profile.reviews.isEmpty)
            Text(
              l10n.noReviewsYet,
              style: TextStyle(color: colors.subFg, fontSize: 13),
            )
          else
            ...profile.reviews.map((r) => _ReviewTile(review: r)),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final CoachReview review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = review.createdAt;
    final date =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.traineeName,
                  style: TextStyle(
                    color: colors.fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                date,
                style: TextStyle(color: colors.mutedFg, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _StarsDisplay(rating: review.rating),
          if ((review.comment ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.comment!.trim(),
              style: TextStyle(color: colors.subFg, fontSize: 13, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Stars
class _StarSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  const _StarSelector({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < rating;
        return IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          constraints: const BoxConstraints(),
          onPressed: onChanged == null ? null : () => onChanged!(i + 1),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: AppColors.primaryColor1,
            size: 34,
          ),
        );
      }),
    );
  }
}

class _StarsDisplay extends StatelessWidget {
  final int rating;
  const _StarsDisplay({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < rating;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.primaryColor1,
          size: 16,
        );
      }),
    );
  }
}
