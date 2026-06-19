import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/dashboard_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutProgressScreen extends StatefulWidget {
  static const routeName = '/WorkoutProgressScreen';
  const WorkoutProgressScreen({super.key});

  @override
  State<WorkoutProgressScreen> createState() => _WorkoutProgressScreenState();
}

class _WorkoutProgressScreenState extends State<WorkoutProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final dash = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.workoutProgressTitle2,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
      ),
      body: dash.loading
          ? const LiaqhPageLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Gradient summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.primaryColor1, AppColors.primaryColor2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Stat(
                          label: l10n.trainees,
                          value: dash.dashboard?.totalTrainees.toString() ?? '0',
                        ),
                        _Stat(
                          label: l10n.onTrack,
                          value: dash.dashboard?.onTrack.toString() ?? '0',
                        ),
                        _Stat(
                          label: l10n.offTrack,
                          value: dash.dashboard?.offTrack.toString() ?? '0',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Icon(Icons.show_chart_rounded,
                      size: 72,
                      color: AppColors.primaryColor1.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(l10n.noProgressYet,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.fg)),
                  const SizedBox(height: 8),
                  Text(l10n.noProgressHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: colors.subFg)),
                ],
              ),
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      );
}
