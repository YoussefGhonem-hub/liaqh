import 'package:fitnessapp/data/models/trainee_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/trainee_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/utils/nutrition_l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_trainee_screen.dart';
import 'trainee_detail_screen.dart';

class TraineesScreen extends StatefulWidget {
  static String routeName = "/TraineesScreen";
  const TraineesScreen({Key? key}) : super(key: key);

  @override
  State<TraineesScreen> createState() => _TraineesScreenState();
}

class _TraineesScreenState extends State<TraineesScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TraineeProvider>().loadTrainees();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      context.read<TraineeProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<TraineeProvider>();
    final l10n = AppLocalizations.of(context);
    // Only individual (personal-gym) coaches may create trainees themselves.
    final canAdd = context.read<AuthProvider>().canCreateTrainees;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.myTrainees,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        actions: [
          if (canAdd)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primaryColor1,
              onPressed: () => Navigator.pushNamed(context, AddTraineeScreen.routeName)
                  .then((_) => context.read<TraineeProvider>().loadTrainees()),
            ),
        ],
      ),
      body: provider.loading
          ? const LiaqhPageLoader()
          : provider.trainees.isEmpty
              ? _EmptyState(
                  onAdd: canAdd
                      ? () => Navigator.pushNamed(context, AddTraineeScreen.routeName)
                      : null)
              : RefreshIndicator(
                  onRefresh: () => context.read<TraineeProvider>().loadTrainees(),
                  child: ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.trainees.length +
                        (provider.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      if (i >= provider.trainees.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: const LiaqhPageLoader(),
                        );
                      }
                      return _TraineeCard(
                        trainee: provider.trainees[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TraineeDetailScreen(
                              traineeId: provider.trainees[i].id,
                              traineeUserId: provider.trainees[i].userId,
                              traineeName: provider.trainees[i].fullName,
                              goal: provider.trainees[i].goal,
                              heightCm: provider.trainees[i].heightCm,
                              currentWeightKg:
                                  provider.trainees[i].currentWeightKg,
                              latestBodyScore:
                                  provider.trainees[i].latestBodyScore,
                              profileImageUrl:
                                  provider.trainees[i].profileImageUrl,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _TraineeCard extends StatelessWidget {
  final TraineeSummary trainee;
  final VoidCallback? onTap;
  const _TraineeCard({required this.trainee, this.onTap});

  Color _goalColor(String goal) {
    switch (goal) {
      case 'Cut': return Colors.red.shade300;
      case 'Bulk': return Colors.blue.shade300;
      case 'Maintain': return Colors.green.shade300;
      default: return Colors.orange.shade300;
    }
  }

  ({Color color, String label, IconData icon}) _sub(String? status) {
    switch (status) {
      case 'Active':
        return (color: AppColors.successColor, label: 'Subscribed', icon: Icons.verified_rounded);
      case 'Expired':
        return (color: AppColors.errorColor, label: 'Expired', icon: Icons.error_outline_rounded);
      default:
        return (color: Colors.grey, label: 'No subscription', icon: Icons.lock_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryColor1.withValues(alpha: 0.15),
            child: Text(
              trainee.fullName.isNotEmpty ? trainee.fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor1),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainee.fullName,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15, color: colors.fg)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _goalColor(trainee.goal).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(goalLabel(l10n, trainee.goal),
                          style: TextStyle(
                              fontSize: 11,
                              color: _goalColor(trainee.goal),
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Text("${trainee.currentWeightKg.toStringAsFixed(1)} kg",
                        style: TextStyle(fontSize: 12, color: colors.subFg)),
                  ],
                ),
                const SizedBox(height: 6),
                Builder(builder: (_) {
                  final s = _sub(trainee.membershipStatus);
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.icon, size: 12, color: s.color),
                        const SizedBox(width: 4),
                        Text(s.label,
                            style: TextStyle(
                                fontSize: 11,
                                color: s.color,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          if (trainee.latestBodyScore != null) ...[
            Column(
              children: [
                Text(
                  trainee.latestBodyScore!.toStringAsFixed(0),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryColor1),
                ),
                Text(l10n.score,
                    style: TextStyle(fontSize: 10, color: colors.subFg)),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAdd;
  const _EmptyState({this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 72, color: AppColors.primaryColor1.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(l10n.noTraineesYet,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colors.fg)),
          const SizedBox(height: 8),
          Text(l10n.noTraineesHint,
              style: TextStyle(fontSize: 14, color: colors.subFg)),
          const SizedBox(height: 24),
          if (onAdd != null)
            ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor1,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(l10n.addTrainee),
          ),
        ],
      ),
    );
  }
}
