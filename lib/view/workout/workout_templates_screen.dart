import 'dart:io';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';

import 'package:file_picker/file_picker.dart';
import 'package:fitnessapp/common_widgets/attachments_view.dart';
import 'package:fitnessapp/data/models/workout_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/workout_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/workout/build_workout_day_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Coach screen: create & manage reusable workout templates, then assign them
/// to trainees with one tap (from the trainee's Workout tab).
class WorkoutTemplatesScreen extends StatefulWidget {
  static const routeName = '/WorkoutTemplatesScreen';
  const WorkoutTemplatesScreen({super.key});

  @override
  State<WorkoutTemplatesScreen> createState() => _WorkoutTemplatesScreenState();
}

class _WorkoutTemplatesScreenState extends State<WorkoutTemplatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<WorkoutProvider>().loadTemplates());
  }

  static const _periods = ['Week', 'Month', 'Quarter'];

  Future<void> _createStructured() async {
    final result = await _askNameAndPeriod(
        AppLocalizations.of(context).newWorkoutTemplate);
    if (result == null || !mounted) return;
    final provider = context.read<WorkoutProvider>();
    final id = await provider.createTemplate(
        name: result.$1, periodType: result.$2);
    if (id == null || !mounted) return;
    // Build its days using the same builder used for trainee programs.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuildWorkoutDayScreen(
          programId: id,
          programName: result.$1,
          traineeId: '',
          traineeName: '',
        ),
      ),
    );
    if (mounted) context.read<WorkoutProvider>().loadTemplates();
  }

  Future<void> _createFromFile() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.any);
    if (picked == null || picked.files.single.path == null || !mounted) return;
    final file = File(picked.files.single.path!);

    final l10n = AppLocalizations.of(context);
    final result = await _askNameAndPeriod(l10n.uploadWorkoutFile);
    if (result == null || !mounted) return;

    final provider = context.read<WorkoutProvider>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
        content: Text(l10n.uploading), duration: const Duration(seconds: 1)));
    final url = await provider.uploadTemplateFile(file);
    if (url == null || !mounted) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.uploadFailed)));
      return;
    }
    final id = await provider.createTemplate(
        name: result.$1, periodType: result.$2, attachmentUrl: url);
    if (id != null && mounted) {
      context.read<WorkoutProvider>().loadTemplates();
    }
  }

  /// Returns (name, periodType) or null if cancelled.
  Future<(String, String)?> _askNameAndPeriod(String title) async {
    final nameCtrl = TextEditingController();
    String period = 'Week';
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return showDialog<(String, String)>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: colors.card,
          title: Text(title, style: TextStyle(color: colors.fg, fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: colors.fg),
                decoration: InputDecoration(labelText: l10n.templateName),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _periods.map((p) {
                  final sel = period == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: sel,
                    selectedColor: AppColors.primaryColor1,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : colors.fg,
                        fontWeight: FontWeight.w600),
                    onSelected: (_) => setLocal(() => period = p),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx, (nameCtrl.text.trim(), period));
              },
              child: Text(l10n.continueLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOptions() {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fitness_center_rounded,
                  color: AppColors.primaryColor1),
              title: Text(l10n.buildFromSystem,
                  style: TextStyle(color: colors.fg, fontWeight: FontWeight.w600)),
              subtitle: Text(l10n.addDaysExercisesHint,
                  style: TextStyle(color: colors.subFg, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _createStructured();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file_rounded,
                  color: AppColors.primaryColor1),
              title: Text(l10n.uploadAFile,
                  style: TextStyle(color: colors.fg, fontWeight: FontWeight.w600)),
              subtitle: Text(l10n.uploadFileHint,
                  style: TextStyle(color: colors.subFg, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _createFromFile();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text(l10n.workoutTemplates,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateOptions,
        backgroundColor: AppColors.primaryColor1,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.newTemplate,
            style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // What-is-this hint.
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor1.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: AppColors.primaryColor1, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.workoutTemplatesHint,
                      style: TextStyle(
                          color: colors.subFg, fontSize: 12, height: 1.4)),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.templatesLoading && provider.templates.isEmpty
                ? const LiaqhPageLoader()
                : provider.templates.isEmpty
                    ? _empty(colors, l10n)
                    : RefreshIndicator(
                  onRefresh: () => context.read<WorkoutProvider>().loadTemplates(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: provider.templates.length,
                    itemBuilder: (_, i) => _TemplateCard(
                      template: provider.templates[i],
                      colors: colors,
                      onOpen: () {
                        final t = provider.templates[i];
                        if (!t.isFile) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BuildWorkoutDayScreen(
                                programId: t.id,
                                programName: t.name,
                                traineeId: '',
                                traineeName: '',
                              ),
                            ),
                          );
                        }
                      },
                      onDelete: () async {
                        final ok = await context
                            .read<WorkoutProvider>()
                            .deleteTemplate(provider.templates[i].id);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.templateDeleted)),
                          );
                        }
                      },
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _empty(AppThemeColors colors, AppLocalizations l10n) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center_rounded,
                size: 64, color: AppColors.primaryColor1.withValues(alpha: 0.35)),
            const SizedBox(height: 16),
            Text(l10n.noTemplatesYet,
                style: TextStyle(
                    color: colors.fg, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                l10n.templatesEmptyHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.subFg, fontSize: 13),
              ),
            ),
          ],
        ),
      );
}

class _TemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final AppThemeColors colors;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  const _TemplateCard({
    required this.template,
    required this.colors,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: onOpen,
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryColor1.withValues(alpha: 0.12),
              child: Icon(
                  template.isFile
                      ? Icons.description_rounded
                      : Icons.fitness_center_rounded,
                  color: AppColors.primaryColor1),
            ),
            title: Text(template.name,
                style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
            subtitle: Text(
              template.isFile
                  ? '${l10n.fileWorkout} · ${template.periodType}'
                  : '${l10n.daysCountLabel(template.dayCount)} · ${template.periodType}',
              style: TextStyle(color: colors.subFg, fontSize: 12),
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: colors.mutedFg),
              onSelected: (v) {
                if (v == 'delete') onDelete();
                if (v == 'open' && !template.isFile) onOpen();
              },
              itemBuilder: (_) => [
                if (!template.isFile)
                  PopupMenuItem(value: 'open', child: Text(l10n.editDays)),
                PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
              ],
            ),
          ),
          if (template.isFile)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: AttachmentsView(urls: [template.attachmentUrl!]),
            ),
        ],
      ),
    );
  }
}
