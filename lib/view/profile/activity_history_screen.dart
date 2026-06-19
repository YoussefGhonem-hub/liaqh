import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/dashboard_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityHistoryScreen extends StatefulWidget {
  static const routeName = '/ActivityHistoryScreen';
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
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
        title: Text(l10n.activityHistoryTitle,
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
                  // Trainees overview (real data)
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.people_outline,
                        label: l10n.trainees,
                        value: dash.dashboard?.totalTrainees.toString() ?? '0',
                        color: AppColors.primaryColor1,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.check_circle_outline,
                        label: l10n.onTrack,
                        value: dash.dashboard?.onTrack.toString() ?? '0',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.warning_amber_outlined,
                        label: l10n.atRisk,
                        value: dash.dashboard?.atRisk.toString() ?? '0',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Icon(Icons.bar_chart_outlined,
                      size: 72,
                      color: AppColors.primaryColor1.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(l10n.noActivityYet,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.fg)),
                  const SizedBox(height: 8),
                  Text(l10n.noActivityHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: colors.subFg)),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10, color: context.colors.subFg)),
            ],
          ),
        ),
      );
}
