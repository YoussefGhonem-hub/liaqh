import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/data/models/coach_profile_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/coach_profile_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CoachProfileEditScreen extends StatefulWidget {
  const CoachProfileEditScreen({super.key});

  static const routeName = '/CoachProfileEditScreen';

  @override
  State<CoachProfileEditScreen> createState() => _CoachProfileEditScreenState();
}

class _CoachProfileEditScreenState extends State<CoachProfileEditScreen> {
  final _headlineCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();
  final _specialtiesCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachProfileProvider>().loadMine();
    });
  }

  @override
  void dispose() {
    _headlineCtrl.dispose();
    _bioCtrl.dispose();
    _yearsCtrl.dispose();
    _specialtiesCtrl.dispose();
    _instagramCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  /// Fill the form controllers once, the first time the profile arrives.
  void _prefill(CoachProfile p) {
    if (_prefilled) return;
    _prefilled = true;
    _headlineCtrl.text = p.headline ?? '';
    _bioCtrl.text = p.bio ?? '';
    _yearsCtrl.text = p.yearsOfExperience?.toString() ?? '';
    _specialtiesCtrl.text = p.specialties ?? '';
    _instagramCtrl.text = p.instagramUrl ?? '';
    _whatsappCtrl.text = p.whatsappNumber ?? '';
  }

  String? _trimToNull(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _saveBasicInfo() async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<CoachProfileProvider>();
    final ok = await provider.updateProfile(
      headline: _trimToNull(_headlineCtrl.text),
      bio: _trimToNull(_bioCtrl.text),
      yearsOfExperience: int.tryParse(_yearsCtrl.text.trim()),
      specialties: _trimToNull(_specialtiesCtrl.text),
      instagramUrl: _trimToNull(_instagramCtrl.text),
      whatsappNumber: _trimToNull(_whatsappCtrl.text),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
    }
  }

  /// Picks an image from the gallery, uploads it and returns the URL.
  Future<String?> _pickAndUploadImage() async {
    final provider = context.read<CoachProfileProvider>();
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1280, imageQuality: 80);
    if (picked == null) return null;
    return provider.uploadImage(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: Text(l10n.editCoachProfile)),
      body: Consumer<CoachProfileProvider>(
        builder: (context, provider, _) {
          final profile = provider.profile;

          if (provider.loading && profile == null) {
            return const LiaqhPageLoader();
          }
          if (profile == null) {
            return const SizedBox.shrink();
          }

          _prefill(profile);

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBasicInfo(l10n, provider),
                  const SizedBox(height: 24),
                  _buildCertifications(l10n, colors, provider, profile),
                  const SizedBox(height: 24),
                  _buildTransformations(l10n, colors, provider, profile),
                  const SizedBox(height: 24),
                  _buildDocuments(l10n, colors, provider, profile),
                  const SizedBox(height: 32),
                ],
              ),
              if (provider.saving)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(child: LiaqhMarkLoader()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Basic info ────────────────────────────────────────────────────────────

  Widget _buildBasicInfo(
      AppLocalizations l10n, CoachProfileProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabeledField(
          label: l10n.headlineLabel,
          controller: _headlineCtrl,
          hint: l10n.headlineHint,
        ),
        const SizedBox(height: 16),
        _LabeledField(
          label: l10n.aboutLabel,
          controller: _bioCtrl,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        _LabeledField(
          label: l10n.yearsExperienceLabel,
          controller: _yearsCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        _LabeledField(
          label: l10n.specialtiesLabel,
          controller: _specialtiesCtrl,
          hint: l10n.specialtiesHint,
        ),
        const SizedBox(height: 16),
        _LabeledField(
          label: l10n.instagramLabel,
          controller: _instagramCtrl,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        _LabeledField(
          label: l10n.whatsappLabel,
          controller: _whatsappCtrl,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: provider.saving ? null : _saveBasicInfo,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  // ── Certifications ──────────────────────────────────────────────────────────

  Widget _buildCertifications(
    AppLocalizations l10n,
    AppThemeColors colors,
    CoachProfileProvider provider,
    CoachProfile profile,
  ) {
    return _Section(
      title: l10n.certifications,
      onAdd: () => _openCertificationSheet(l10n, colors, provider),
      addLabel: l10n.addCertification,
      children: [
        if (profile.certifications.isEmpty)
          _EmptyHint(colors: colors)
        else
          for (final cert in profile.certifications)
            _CardTile(
              colors: colors,
              leading: cert.imageUrl != null && cert.imageUrl!.isNotEmpty
                  ? _Thumb(url: cert.imageUrl!, colors: colors)
                  : const Icon(Icons.workspace_premium_outlined,
                      color: AppColors.primaryColor1),
              title: cert.title,
              subtitle: [cert.issuer, cert.year?.toString()]
                  .where((e) => e != null && e.isNotEmpty)
                  .join(' • '),
              onDelete: () => provider.deleteCertification(cert.id),
            ),
      ],
    );
  }

  Future<void> _openCertificationSheet(
    AppLocalizations l10n,
    AppThemeColors colors,
    CoachProfileProvider provider,
  ) async {
    final titleCtrl = TextEditingController();
    final issuerCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    String? imageUrl;
    bool busy = false;

    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.addCertification,
                        style: Theme.of(sheetCtx).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _LabeledField(
                        label: l10n.certTitleLabel, controller: titleCtrl),
                    const SizedBox(height: 12),
                    _LabeledField(
                        label: l10n.issuerLabel, controller: issuerCtrl),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: l10n.yearLabel,
                      controller: yearCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () async {
                              setSheetState(() => busy = true);
                              final url = await _pickAndUploadImage();
                              setSheetState(() {
                                imageUrl = url ?? imageUrl;
                                busy = false;
                              });
                            },
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(imageUrl == null
                          ? l10n.addPhoto
                          : '${l10n.addPhoto} ✓'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(sheetCtx, false),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: titleCtrl.text.trim().isEmpty
                                ? null
                                : () => Navigator.pop(sheetCtx, true),
                            child: Text(l10n.save),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (added == true) {
      await provider.addCertification(
        title: titleCtrl.text.trim(),
        issuer: _trimToNull(issuerCtrl.text),
        year: int.tryParse(yearCtrl.text.trim()),
        imageUrl: imageUrl,
      );
    }

    titleCtrl.dispose();
    issuerCtrl.dispose();
    yearCtrl.dispose();
  }

  // ── Transformations ─────────────────────────────────────────────────────────

  Widget _buildTransformations(
    AppLocalizations l10n,
    AppThemeColors colors,
    CoachProfileProvider provider,
    CoachProfile profile,
  ) {
    return _Section(
      title: l10n.transformationsTitle,
      onAdd: () => _openTransformationSheet(l10n, colors, provider),
      addLabel: l10n.addTransformation,
      children: [
        if (profile.transformations.isEmpty)
          _EmptyHint(colors: colors)
        else
          for (final t in profile.transformations)
            _CardTile(
              colors: colors,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Thumb(url: t.beforeImageUrl, colors: colors, size: 40),
                  const SizedBox(width: 4),
                  _Thumb(url: t.afterImageUrl, colors: colors, size: 40),
                ],
              ),
              title: (t.caption ?? '').isEmpty ? '—' : t.caption!,
              subtitle: t.durationText ?? '',
              onDelete: () => provider.deleteTransformation(t.id),
            ),
      ],
    );
  }

  Future<void> _openTransformationSheet(
    AppLocalizations l10n,
    AppThemeColors colors,
    CoachProfileProvider provider,
  ) async {
    final captionCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    String? beforeUrl;
    String? afterUrl;
    bool busyBefore = false;
    bool busyAfter = false;

    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.addTransformation,
                        style: Theme.of(sheetCtx).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ImagePickButton(
                            label: l10n.beforeLabel,
                            picked: beforeUrl != null,
                            busy: busyBefore,
                            colors: colors,
                            onTap: () async {
                              setSheetState(() => busyBefore = true);
                              final url = await _pickAndUploadImage();
                              setSheetState(() {
                                beforeUrl = url ?? beforeUrl;
                                busyBefore = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ImagePickButton(
                            label: l10n.afterLabel,
                            picked: afterUrl != null,
                            busy: busyAfter,
                            colors: colors,
                            onTap: () async {
                              setSheetState(() => busyAfter = true);
                              final url = await _pickAndUploadImage();
                              setSheetState(() {
                                afterUrl = url ?? afterUrl;
                                busyAfter = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                        label: l10n.captionLabel, controller: captionCtrl),
                    const SizedBox(height: 12),
                    _LabeledField(
                        label: l10n.durationResultLabel,
                        controller: durationCtrl),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(sheetCtx, false),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(sheetCtx, true),
                            child: Text(l10n.save),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (added == true) {
      await provider.addTransformation(
        beforeImageUrl: beforeUrl,
        afterImageUrl: afterUrl,
        caption: _trimToNull(captionCtrl.text),
        durationText: _trimToNull(durationCtrl.text),
      );
    }

    captionCtrl.dispose();
    durationCtrl.dispose();
  }

  // ── Documents ───────────────────────────────────────────────────────────────

  Widget _buildDocuments(
    AppLocalizations l10n,
    AppThemeColors colors,
    CoachProfileProvider provider,
    CoachProfile profile,
  ) {
    return _Section(
      title: l10n.documentsTitle,
      onAdd: () => _pickAndUploadFile(provider),
      addLabel: l10n.uploadDocument,
      children: [
        if (profile.files.isEmpty)
          _EmptyHint(colors: colors)
        else
          for (final f in profile.files)
            _CardTile(
              colors: colors,
              leading: const Icon(Icons.picture_as_pdf_outlined,
                  color: AppColors.primaryColor1),
              title: f.fileName,
              subtitle: '',
              onDelete: () => provider.deleteFile(f.id),
            ),
      ],
    );
  }

  Future<void> _pickAndUploadFile(CoachProfileProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    await provider.uploadFile(File(path));
  }
}

// ── Reusable private widgets ──────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String addLabel;
  final VoidCallback onAdd;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.addLabel,
    required this.onAdd,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: Text(addLabel),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  final AppThemeColors colors;
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onDelete;

  const _CardTile({
    required this.colors,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colors.subFg),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.errorColor,
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? url;
  final AppThemeColors colors;
  final double size;

  const _Thumb({required this.url, required this.colors, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size,
        height: size,
        color: colors.divider,
        child: hasUrl
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.broken_image_outlined, color: colors.mutedFg),
              )
            : Icon(Icons.image_outlined, color: colors.mutedFg),
      ),
    );
  }
}

class _ImagePickButton extends StatelessWidget {
  final String label;
  final bool picked;
  final bool busy;
  final AppThemeColors colors;
  final VoidCallback onTap;

  const _ImagePickButton({
    required this.label,
    required this.picked,
    required this.busy,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: colors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: picked ? AppColors.primaryColor1 : colors.divider,
          ),
        ),
        child: Center(
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      picked ? Icons.check_circle : Icons.add_a_photo_outlined,
                      color: picked
                          ? AppColors.primaryColor1
                          : colors.subFg,
                    ),
                    const SizedBox(height: 6),
                    Text(label,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final AppThemeColors colors;
  const _EmptyHint({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '—',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: colors.mutedFg),
      ),
    );
  }
}
