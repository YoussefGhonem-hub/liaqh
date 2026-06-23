import 'package:fitnessapp/common_widgets/rest_timer_sheet.dart';
import 'package:fitnessapp/data/models/workout_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/workout_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a workout day's exercises with the coach's prescription and the
/// per-exercise coach comments. Coaches can add/remove comments; trainees read.
class WorkoutDayDetailScreen extends StatelessWidget {
  final WorkoutDay day;
  final String traineeId;
  final String programId;

  const WorkoutDayDetailScreen({
    Key? key,
    required this.day,
    required this.traineeId,
    required this.programId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final isCoach = context.watch<AuthProvider>().isCoach;
    // Re-read the latest day from the provider so comments refresh live.
    final program = context.watch<WorkoutProvider>().currentProgram;
    final liveDay = program?.days.firstWhere(
          (d) => d.id == day.id,
          orElse: () => day,
        ) ??
        day;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
        title: Text(liveDay.dayName,
            style: TextStyle(
                color: colors.fg, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: l10n.restTimer,
            icon: const Icon(Icons.timer_outlined,
                color: AppColors.primaryColor1),
            onPressed: () => RestTimerSheet.show(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        itemCount: liveDay.exercises.length,
        itemBuilder: (context, i) => _ExerciseCommentCard(
          exercise: liveDay.exercises[i],
          isCoach: isCoach,
          traineeId: traineeId,
          programId: programId,
          l10n: l10n,
        ),
      ),
    );
  }
}

class _ExerciseCommentCard extends StatelessWidget {
  final WorkoutExerciseItem exercise;
  final bool isCoach;
  final String traineeId;
  final String programId;
  final AppLocalizations l10n;

  const _ExerciseCommentCard({
    required this.exercise,
    required this.isCoach,
    required this.traineeId,
    required this.programId,
    required this.l10n,
  });

  Future<void> _watchVideo(BuildContext context, String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the video.')),
        );
      }
    }
  }

  Future<void> _addComment(BuildContext context) async {
    final ctrl = TextEditingController();
    final colors = context.colors;
    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.addComment, style: TextStyle(color: colors.fg)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 4,
          minLines: 2,
          style: TextStyle(color: colors.fg),
          decoration: InputDecoration(
            hintText: l10n.commentHint,
            hintStyle: TextStyle(color: colors.mutedFg),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor1,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(l10n.add),
          ),
        ],
      ),
    );

    if (text != null && text.isNotEmpty && context.mounted) {
      final ok = await context
          .read<WorkoutProvider>()
          .addComment(exercise.id, text, programId: programId);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.commentAdded),
          backgroundColor: AppColors.successColor,
        ));
      }
    }
  }

  Future<void> _deleteComment(BuildContext context, WorkoutComment c) async {
    final ok = await context
        .read<WorkoutProvider>()
        .deleteComment(c.id, programId: programId);
    if (!ok && context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.failedToDelete)));
    }
  }

  void _showFullImage(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) => Stack(
        children: [
          // Zoomable full-screen image
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, p) => p == null
                      ? child
                      : const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white)),
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 64),
                ),
              ),
            ),
          ),
          // Title
          Positioned(
            left: 16,
            right: 64,
            bottom: 40,
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(ctx).padding.top + 8,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final weight = exercise.startingWeightKg != null
        ? ' · ${exercise.startingWeightKg!.toStringAsFixed(1)} kg'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: exercise.fullImage != null
                      ? () => _showFullImage(context, exercise.fullImage!,
                          exercise.exerciseNameEn)
                      : null,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor1.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: exercise.listImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                exercise.listImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.fitness_center_rounded,
                                    color: AppColors.primaryColor1,
                                    size: 20),
                              ),
                              // subtle zoom hint
                              const Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(Icons.zoom_out_map_rounded,
                                      size: 11, color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        : const Icon(Icons.fitness_center_rounded,
                            color: AppColors.primaryColor1, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.exerciseNameEn,
                          style: TextStyle(
                              color: colors.fg,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('${exercise.sets} × ${exercise.repsTarget}$weight',
                          style: TextStyle(color: colors.subFg, fontSize: 12)),
                      if (exercise.videoUrl != null &&
                          exercise.videoUrl!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: InkWell(
                            onTap: () => _watchVideo(context, exercise.videoUrl!),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_circle_fill_rounded,
                                    size: 16, color: AppColors.primaryColor1),
                                const SizedBox(width: 4),
                                Text(AppLocalizations.of(context).watchVideo,
                                    style: const TextStyle(
                                        color: AppColors.primaryColor1,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colors.divider),

          // Comments
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                const Icon(Icons.comment_rounded,
                    size: 15, color: AppColors.primaryColor1),
                const SizedBox(width: 6),
                Text(l10n.coachComments,
                    style: TextStyle(
                        color: colors.fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                if (isCoach)
                  TextButton.icon(
                    onPressed: () => _addComment(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.addComment,
                        style: const TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor1,
                        padding: const EdgeInsets.symmetric(horizontal: 8)),
                  ),
              ],
            ),
          ),

          if (exercise.comments.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(l10n.noComments,
                  style: TextStyle(color: colors.mutedFg, fontSize: 12)),
            )
          else
            ...exercise.comments.map((c) => _CommentRow(
                  comment: c,
                  canDelete: isCoach,
                  onDelete: () => _deleteComment(context, c),
                )),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final WorkoutComment comment;
  final bool canDelete;
  final VoidCallback onDelete;
  const _CommentRow({
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = DateTime.tryParse(comment.createdAt)?.toLocal();
    final dateStr =
        date != null ? DateFormat('MMM d, h:mm a').format(date) : '';

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.coachName,
                        style: const TextStyle(
                            color: AppColors.primaryColor1,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(dateStr,
                        style: TextStyle(color: colors.mutedFg, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(comment.text,
                    style: TextStyle(
                        color: colors.fg, fontSize: 13, height: 1.35)),
              ],
            ),
          ),
          if (canDelete)
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close_rounded, size: 16, color: colors.mutedFg),
            ),
        ],
      ),
    );
  }
}
