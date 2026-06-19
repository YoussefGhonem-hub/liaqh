import 'dart:io';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/data/models/inbody_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/inbody_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class AddInBodyScreen extends StatefulWidget {
  final String traineeId;
  final String traineeName;

  const AddInBodyScreen({
    Key? key,
    required this.traineeId,
    required this.traineeName,
  }) : super(key: key);

  @override
  State<AddInBodyScreen> createState() => _AddInBodyScreenState();
}

class _AddInBodyScreenState extends State<AddInBodyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _weightCtrl   = TextEditingController();
  final _muscleCtrl   = TextEditingController();
  final _fatCtrl      = TextEditingController();
  final _waterCtrl    = TextEditingController();
  final _visceralCtrl = TextEditingController();
  final _bmrCtrl      = TextEditingController();
  final _notesCtrl    = TextEditingController();

  // Multiple scans — picked files and their uploaded URLs (paired by index)
  final List<File> _pickedFiles = [];
  final List<String?> _uploadedUrls = []; // null = not yet uploaded
  bool _uploading = false;

  String? _validationError;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _weightCtrl.dispose(); _muscleCtrl.dispose(); _fatCtrl.dispose();
    _waterCtrl.dispose();  _visceralCtrl.dispose(); _bmrCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Scan helpers ──────────────────────────────────────────────────────────
  Future<void> _pickScan() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (final f in result.files) {
          if (f.path != null) {
            _pickedFiles.add(File(f.path!));
            _uploadedUrls.add(null);
          }
        }
      });
    }
  }

  void _removeScan(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
      _uploadedUrls.removeAt(index);
    });
  }

  Future<void> _uploadAll() async {
    final provider = context.read<InBodyProvider>();
    setState(() => _uploading = true);
    for (int i = 0; i < _pickedFiles.length; i++) {
      if (_uploadedUrls[i] != null) continue; // already done
      final url = await provider.uploadScan(_pickedFiles[i], widget.traineeId);
      if (url != null) {
        setState(() => _uploadedUrls[i] = url);
      }
    }
    setState(() => _uploading = false);
    if (mounted) {
      final done = _uploadedUrls.where((u) => u != null).length;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.scanCount(done)),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }

  List<String> get _confirmedUrls =>
      _uploadedUrls.whereType<String>().toList();

  // ── Validation + submit ───────────────────────────────────────────────────
  String? _validate() {
    final wText = _weightCtrl.text.trim();
    final mText = _muscleCtrl.text.trim();
    final fText = _fatCtrl.text.trim();

    // Attachment-only save: a trainee can upload a photo/PDF of their InBody
    // printout without typing the numbers. If the metrics are all blank but at
    // least one attachment is added, allow it.
    if (wText.isEmpty && mText.isEmpty && fText.isEmpty && _pickedFiles.isNotEmpty) {
      return null;
    }

    double? w = double.tryParse(wText);
    double? m = double.tryParse(mText);
    double? f = double.tryParse(fText);
    if (w == null || w <= 0) return 'Enter a valid weight (or add an attachment).';
    if (m == null || m <= 0) return 'Enter a valid muscle mass.';
    if (f == null || f <= 0 || f >= 100) return 'Body fat % must be 0–100.';
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) {
      setState(() => _validationError = err);
      // Surface the error even if the user tapped Save from the Attachments tab,
      // then take them to the form so they can fix it.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.errorColor),
      );
      _tabCtrl.animateTo(0);
      return;
    }
    setState(() => _validationError = null);

    // Auto-upload any pending scans before saving
    if (_pickedFiles.any((f) => _uploadedUrls[_pickedFiles.indexOf(f)] == null)) {
      await _uploadAll();
    }

    final provider = context.read<InBodyProvider>();
    final ok = await provider.addMeasurement(AddInBodyRequest(
      traineeId:           widget.traineeId,
      weightKg:            double.tryParse(_weightCtrl.text) ?? 0,
      muscleMassKg:        double.tryParse(_muscleCtrl.text) ?? 0,
      bodyFatPercentage:   double.tryParse(_fatCtrl.text) ?? 0,
      bodyWaterPercentage: _waterCtrl.text.isNotEmpty
          ? double.tryParse(_waterCtrl.text) : null,
      visceralFatLevel:    _visceralCtrl.text.isNotEmpty
          ? int.tryParse(_visceralCtrl.text) : null,
      bmr:                 _bmrCtrl.text.isNotEmpty
          ? int.tryParse(_bmrCtrl.text) : null,
      coachNotes:          _notesCtrl.text.trim().isNotEmpty
          ? _notesCtrl.text.trim() : null,
      scanPhotoUrls:       _confirmedUrls,
    ));
    if (ok && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<InBodyProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(widget.traineeName,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.fg,
                fontSize: 17)),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primaryColor1,
          unselectedLabelColor: colors.subFg,
          indicatorColor: AppColors.primaryColor1,
          tabs: [
            Tab(icon: const Icon(Icons.edit_note_outlined), text: l10n.fillForm),
            Tab(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.upload_file_outlined),
                  if (_pickedFiles.isNotEmpty)
                    Positioned(
                      right: -6, top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor1,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_pickedFiles.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              ),
              text: l10n.scans,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildFormTab(provider, l10n),
          _buildScansTab(provider, l10n),
        ],
      ),
    );
  }

  // ── Form Tab ──────────────────────────────────────────────────────────────
  Widget _buildFormTab(InBodyProvider provider, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(l10n.required.toUpperCase()),
          _numField(_weightCtrl, l10n.weightKg),
          const SizedBox(height: 12),
          _numField(_muscleCtrl, l10n.muscleMass),
          const SizedBox(height: 12),
          _numField(_fatCtrl, l10n.bodyFat),
          const SizedBox(height: 20),
          _sectionLabel(l10n.optional.toUpperCase()),
          _numField(_waterCtrl, l10n.bodyWater),
          const SizedBox(height: 12),
          _numField(_visceralCtrl, l10n.visceralFat, isInt: true),
          const SizedBox(height: 12),
          _numField(_bmrCtrl, l10n.bmr, isInt: true),
          const SizedBox(height: 12),
          RoundTextField(
            textEditingController: _notesCtrl,
            hintText: l10n.notesOptional,
            icon: 'assets/icons/message_icon.png',
            textInputType: TextInputType.multiline,
          ),
          if (_confirmedUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.attach_file,
                    color: AppColors.successColor, size: 16),
                const SizedBox(width: 6),
                Text(l10n.scanCount(_confirmedUrls.length),
                    style: const TextStyle(
                        color: AppColors.successColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                TextButton(
                  onPressed: () => _tabCtrl.animateTo(1),
                  child: Text(l10n.manage),
                ),
              ],
            ),
          ],
          if (_validationError != null || provider.error != null) ...[
            const SizedBox(height: 8),
            Text(_validationError ?? provider.error!,
                style: const TextStyle(
                    color: AppColors.errorColor, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          provider.loading || _uploading
              ? const LiaqhPageLoader()
              : RoundGradientButton(
                  title: l10n.saveMeasurement,
                  onPressed: _submit,
                ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Scans Tab ─────────────────────────────────────────────────────────────
  Widget _buildScansTab(InBodyProvider provider, AppLocalizations l10n) {
    final colors = context.colors;
    return SizedBox.expand(child: Column(
      children: [
        // Header (only once attachments exist — when empty, the centered empty
        // state below provides the single "Add Attachments" action).
        if (_pickedFiles.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ElevatedButton.icon(
                onPressed: _pickScan,
                icon: const Icon(Icons.attach_file_rounded, size: 18),
                label: Text(l10n.addScans),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor1,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${_pickedFiles.length} file(s) selected — '
              '${_confirmedUrls.length} ${l10n.uploaded.toLowerCase()}.',
              style: TextStyle(color: colors.subFg, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // File grid
        Expanded(
          child: _pickedFiles.isEmpty
              ? _EmptyScans(onAdd: _pickScan)
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: _pickedFiles.length,
                  itemBuilder: (_, i) => _ScanTile(
                    file: _pickedFiles[i],
                    uploaded: _uploadedUrls[i] != null,
                    onRemove: () => _removeScan(i),
                    uploadedLabel: l10n.uploaded,
                    pendingLabel: l10n.pending,
                  ),
                ),
        ),

        // Upload all button
        if (_pickedFiles.isNotEmpty)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  if (_confirmedUrls.length == _pickedFiles.length)
                    // All uploaded — save button
                    ElevatedButton.icon(
                      onPressed: provider.loading ? null : _submit,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(l10n.saveMeasurement),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor1,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: (_uploading || provider.loading)
                          ? null
                          : _uploadAll,
                      icon: _uploading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                          _uploading
                              ? l10n.uploading
                              : l10n.pending),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor1,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  if (_confirmedUrls.isNotEmpty &&
                      _confirmedUrls.length < _pickedFiles.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton(
                        onPressed: provider.loading ? null : _submit,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor1,
                          side: const BorderSide(
                              color: AppColors.primaryColor1),
                          minimumSize: const Size(double.infinity, 46),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.scanCount(_confirmedUrls.length)),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    ));
  }

  Widget _sectionLabel(String text) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: TextStyle(
              color: colors.subFg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0)),
    );
  }

  Widget _numField(TextEditingController ctrl, String hint,
          {bool isInt = false}) =>
      RoundTextField(
        textEditingController: ctrl,
        hintText: hint,
        icon: 'assets/icons/user_icon.png',
        textInputType: isInt
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
      );
}

// ── Scan tile ─────────────────────────────────────────────────────────────────
class _ScanTile extends StatelessWidget {
  final File file;
  final bool uploaded;
  final VoidCallback onRemove;
  final String uploadedLabel;
  final String pendingLabel;

  const _ScanTile({
    required this.file,
    required this.uploaded,
    required this.onRemove,
    required this.uploadedLabel,
    required this.pendingLabel,
  });

  bool get _isImage {
    final ext = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  IconData get _fileIcon {
    final ext = file.path.split('.').last.toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf_outlined;
    if (['doc', 'docx'].contains(ext)) return Icons.description_outlined;
    if (['xls', 'xlsx'].contains(ext)) return Icons.table_chart_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fileName = file.path.split('/').last.split('\\').last;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.listTile,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: uploaded
                  ? AppColors.successColor
                  : colors.divider,
              width: uploaded ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: _isImage
                ? Image.file(file,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_fileIcon,
                            size: 40,
                            color: AppColors.primaryColor1.withValues(alpha: 0.7)),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            fileName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                color: colors.fg,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        // Status badge
        Positioned(
          top: 8, left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: uploaded
                  ? AppColors.successColor
                  : Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  uploaded ? Icons.cloud_done_outlined : Icons.schedule,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  uploaded ? uploadedLabel : pendingLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        // Remove button
        Positioned(
          top: 6, right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 26, height: 26,
              decoration: const BoxDecoration(
                color: AppColors.errorColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyScans extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyScans({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.attach_file_rounded,
              size: 64, color: AppColors.primaryColor1.withValues(alpha: 0.35)),
          const SizedBox(height: 16),
          Text(l10n.noScansAdded,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.colors.fg)),
          const SizedBox(height: 8),
          Text(l10n.scansHint,
              style: TextStyle(fontSize: 13, color: context.colors.subFg)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.attach_file_rounded),
            label: Text(l10n.addScans),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor1,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}
