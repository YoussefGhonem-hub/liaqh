import 'dart:io';
import 'package:fitnessapp/data/models/progress_models.dart';
import 'package:fitnessapp/data/services/api_service.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/progress_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Progress Body" — a trainee's timeline of progress photos + notes.
/// Works for the trainee (self) and the coach (viewing a trainee).
class ProgressBodyScreen extends StatefulWidget {
  static const routeName = '/ProgressBodyScreen';
  final String traineeId;
  final String traineeName;

  const ProgressBodyScreen({
    Key? key,
    required this.traineeId,
    required this.traineeName,
  }) : super(key: key);

  @override
  State<ProgressBodyScreen> createState() => _ProgressBodyScreenState();
}

class _ProgressBodyScreenState extends State<ProgressBodyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().loadHistory(widget.traineeId);
    });
  }

  Future<void> _openAdd() async {
    final auth = context.read<AuthProvider>();
    final isCoach = auth.isCoach || auth.currentUser?.role == 'GymAdmin';
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddProgressSheet(
        traineeId: widget.traineeId,
        coachUserId: isCoach ? auth.currentUser?.userId : null,
        coachName: isCoach ? auth.currentUser?.fullName : null,
      ),
    );
    if (added == true && mounted) {
      context.read<ProgressProvider>().loadHistory(widget.traineeId);
    }
  }

  Future<void> _confirmDelete(ProgressEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.deleteEntry),
        content: Text(l10n.deleteEntryConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<ProgressProvider>().deleteEntry(entry.id, widget.traineeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
        title: Text(l10n.progressBody,
            style: TextStyle(
                color: colors.fg, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: AppColors.primaryColor1,
        icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
        label: Text(l10n.addProgressEntry,
            style: const TextStyle(color: Colors.white)),
      ),
      body: provider.loading && provider.history.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.history.isEmpty
              ? _EmptyState(l10n: l10n, colors: colors)
              : RefreshIndicator(
                  onRefresh: () => provider.loadHistory(widget.traineeId),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: provider.history.length,
                    itemBuilder: (context, i) => _ProgressCard(
                      entry: provider.history[i],
                      onDelete: () => _confirmDelete(provider.history[i]),
                    ),
                  ),
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final dynamic colors;
  const _EmptyState({required this.l10n, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined, size: 64, color: colors.mutedFg),
          const SizedBox(height: 16),
          Text(l10n.noProgressEntries,
              style: TextStyle(
                  color: colors.subFg,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(l10n.noProgressEntriesHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.mutedFg, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Progress card (one timeline entry) ────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final ProgressEntry entry;
  final VoidCallback onDelete;
  const _ProgressCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final fileBase = context.read<ApiService>().fileBaseUrl;
    final date = DateTime.tryParse(entry.recordedAt)?.toLocal();
    final dateStr =
        date != null ? DateFormat('MMM d, yyyy · h:mm a').format(date) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: AppColors.primaryColor1),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(dateStr,
                      style: TextStyle(
                          color: colors.fg,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
                if (entry.uploadedByCoach)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor1.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.uploaderName,
                      style: const TextStyle(
                          color: AppColors.primaryColor1,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                IconButton(
                  tooltip: l10n.deleteEntry,
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 20, color: colors.mutedFg),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),

          // Title
          if (entry.title != null && entry.title!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(entry.title!,
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),

          // Attachments
          if (entry.photoUrls.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: entry.photoUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final raw = entry.photoUrls[i];
                  final url = '$fileBase$raw';
                  final isImage = _isImageFile(raw);
                  return GestureDetector(
                    onTap: () => isImage
                        ? _openFullScreen(context, url)
                        : _openExternal(url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isImage
                          ? Image.network(
                              url,
                              width: 130,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 130,
                                color: colors.listTile,
                                child: Icon(Icons.broken_image_outlined,
                                    color: colors.mutedFg),
                              ),
                            )
                          : Container(
                              width: 130,
                              height: 150,
                              color: colors.listTile,
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.insert_drive_file_rounded,
                                      color: AppColors.primaryColor1, size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    raw.split('/').last,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: colors.subFg, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),

          // Notes
          if (entry.notes != null && entry.notes!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Text(entry.notes!,
                  style: TextStyle(
                      color: colors.subFg, fontSize: 13, height: 1.4)),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openFullScreen(BuildContext context, String url) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    ));
  }
}

/// True when the path/URL points at a displayable image.
bool _isImageFile(String path) {
  final p = path.toLowerCase().split('?').first;
  return p.endsWith('.jpg') ||
      p.endsWith('.jpeg') ||
      p.endsWith('.png') ||
      p.endsWith('.gif') ||
      p.endsWith('.webp') ||
      p.endsWith('.bmp') ||
      p.endsWith('.heic');
}

// ── Add progress entry bottom sheet ───────────────────────────────────────────
class _AddProgressSheet extends StatefulWidget {
  final String traineeId;
  final String? coachUserId;
  final String? coachName;
  const _AddProgressSheet({
    required this.traineeId,
    this.coachUserId,
    this.coachName,
  });

  @override
  State<_AddProgressSheet> createState() => _AddProgressSheetState();
}

class _AddProgressSheetState extends State<_AddProgressSheet> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<File> _pickedFiles = [];
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    // Allow any file (images, PDFs, documents) as attachments.
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (final f in result.files) {
          if (f.path != null) _pickedFiles.add(File(f.path!));
        }
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final title = _titleCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    if (_pickedFiles.isEmpty && notes.isEmpty && title.isEmpty) {
      setState(() => _error = l10n.addPhotoOrNote);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final provider = context.read<ProgressProvider>();

    // Upload each attachment first
    final urls = <String>[];
    for (final file in _pickedFiles) {
      final url = await provider.uploadPhoto(file, widget.traineeId);
      if (url != null) urls.add(url);
    }

    final ok = await provider.addEntry(AddProgressRequest(
      traineeId: widget.traineeId,
      title: title.isNotEmpty ? title : null,
      notes: notes.isNotEmpty ? notes : null,
      photoUrls: urls,
      coachUserId: widget.coachUserId,
      coachName: widget.coachName,
    ));

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.progressSaved),
        backgroundColor: AppColors.successColor,
      ));
      Navigator.pop(context, true);
    } else {
      setState(() => _error = provider.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.addProgressEntry,
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            // Title (optional)
            Text('Title',
                style: TextStyle(
                    color: colors.subFg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.divider),
              ),
              child: TextField(
                controller: _titleCtrl,
                maxLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: colors.fg, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add a title (optional)',
                  hintStyle: TextStyle(color: colors.mutedFg, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Attachments
            Text(l10n.progressPhotos,
                style: TextStyle(
                    color: colors.subFg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: _pickPhotos,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.divider),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_rounded,
                              color: AppColors.primaryColor1, size: 26),
                          const SizedBox(height: 4),
                          Text(l10n.addPhotos,
                              style:
                                  TextStyle(color: colors.subFg, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ..._pickedFiles.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _isImageFile(e.value.path)
                                  ? Image.file(e.value,
                                      width: 90, height: 90, fit: BoxFit.cover)
                                  : Container(
                                      width: 90,
                                      height: 90,
                                      color: colors.card,
                                      padding: const EdgeInsets.all(6),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                              Icons.insert_drive_file_rounded,
                                              color: AppColors.primaryColor1,
                                              size: 28),
                                          const SizedBox(height: 4),
                                          Text(
                                            e.value.path.split('/').last,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: colors.subFg,
                                                fontSize: 8),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _pickedFiles.removeAt(e.key)),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                      color: AppColors.errorColor,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description (optional)
            Text('Description',
                style: TextStyle(
                    color: colors.subFg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.divider),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 4,
                minLines: 2,
                style: TextStyle(color: colors.fg, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.progressNotesHint,
                  hintStyle: TextStyle(color: colors.mutedFg, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.errorColor, fontSize: 13)),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor1,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l10n.saveProgress,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
