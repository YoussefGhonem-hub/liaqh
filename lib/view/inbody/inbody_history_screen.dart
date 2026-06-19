import 'package:fitnessapp/common_widgets/attachments_view.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/data/models/inbody_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/inbody_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_inbody_screen.dart';

class InBodyHistoryScreen extends StatefulWidget {
  final String traineeId;
  final String traineeName;

  const InBodyHistoryScreen({
    Key? key,
    required this.traineeId,
    required this.traineeName,
  }) : super(key: key);

  @override
  State<InBodyHistoryScreen> createState() => _InBodyHistoryScreenState();
}

class _InBodyHistoryScreenState extends State<InBodyHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InBodyProvider>().loadHistory(widget.traineeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<InBodyProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text('${widget.traineeName} — ${l10n.inBody}',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.fg,
                fontSize: 16)),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.primaryColor1),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddInBodyScreen(
                  traineeId: widget.traineeId,
                  traineeName: widget.traineeName,
                ),
              ),
            ).then((added) {
              if (added == true) {
                context.read<InBodyProvider>().loadHistory(widget.traineeId);
              }
            }),
          ),
        ],
      ),
      body: provider.loading
          ? const LiaqhPageLoader()
          : provider.history.isEmpty
              ? _EmptyState(
                  onAdd: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddInBodyScreen(
                        traineeId: widget.traineeId,
                        traineeName: widget.traineeName,
                      ),
                    ),
                  ).then((added) {
                    if (added == true) {
                      context
                          .read<InBodyProvider>()
                          .loadHistory(widget.traineeId);
                    }
                  }),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<InBodyProvider>().loadHistory(widget.traineeId),
                  child: CustomScrollView(
                    slivers: [
                      // Latest measurement summary card
                      SliverToBoxAdapter(
                        child: _LatestSummaryCard(
                            measurement: provider.history.first),
                      ),
                      // Progress charts
                      if (provider.history.length >= 2) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                            child: Text(l10n.progress,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: colors.fg)),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _ProgressCharts(history: provider.history),
                        ),
                      ],
                      // History list
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: Text(l10n.allMeasurements,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: colors.fg)),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _MeasurementCard(
                                measurement: provider.history[i], index: i),
                            childCount: provider.history.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),
    );
  }
}

// ── Latest Summary ────────────────────────────────────────────────────────────
class _LatestSummaryCard extends StatelessWidget {
  final InBodyMeasurement measurement;
  const _LatestSummaryCard({required this.measurement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor1, AppColors.primaryColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(l10n.latestMeasurement,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          // Body Score ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: measurement.bodyScore / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    measurement.bodyScore.toStringAsFixed(1),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800),
                  ),
                  Text(l10n.score,
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(l10n.weight, '${measurement.weightKg.toStringAsFixed(1)} kg'),
              _Stat(l10n.muscleMass, '${measurement.muscleMassKg.toStringAsFixed(1)} kg'),
              _Stat(l10n.bodyFat, '${measurement.bodyFatPercentage.toStringAsFixed(1)} %'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(measurement.recordedAt),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      );
}

// ── Progress Charts ───────────────────────────────────────────────────────────
class _ProgressCharts extends StatelessWidget {
  final List<InBodyMeasurement> history;
  const _ProgressCharts({required this.history});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Charts show oldest → newest
    final ordered = history.reversed.toList();

    return SizedBox(
      height: 160,
      child: PageView(
        children: [
          _LineChart(
            title: l10n.bodyScore,
            color: AppColors.primaryColor1,
            spots: ordered.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.bodyScore)).toList(),
          ),
          _LineChart(
            title: '${l10n.weight} (kg)',
            color: Colors.blue,
            spots: ordered.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.weightKg)).toList(),
          ),
          _LineChart(
            title: '${l10n.muscleMass} (kg)',
            color: Colors.green,
            spots: ordered.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.muscleMassKg)).toList(),
          ),
          _LineChart(
            title: '${l10n.bodyFat} (%)',
            color: Colors.red,
            spots: ordered.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.bodyFatPercentage)).toList(),
          ),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final String title;
  final Color color;
  final List<FlSpot> spots;
  const _LineChart(
      {required this.title, required this.color, required this.spots});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                              radius: 4,
                              color: color,
                              strokeColor: Colors.white,
                              strokeWidth: 2),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('← swipe for more charts →',
              style: TextStyle(
                  color: colors.subFg,
                  fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Measurement Card ──────────────────────────────────────────────────────────
class _MeasurementCard extends StatelessWidget {
  final InBodyMeasurement measurement;
  final int index;
  const _MeasurementCard({required this.measurement, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final trendIcon = _trendIcon(measurement.trend);
    final trendColor = _trendColor(measurement.trend);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(measurement.recordedAt),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.fg,
                      fontSize: 14),
                ),
              ),
              if (index > 0) Icon(trendIcon, color: trendColor, size: 18),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor1.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${l10n.score} ${measurement.bodyScore.toStringAsFixed(1)}',
                  style: const TextStyle(
                      color: AppColors.primaryColor1,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _chip('⚖ ${measurement.weightKg.toStringAsFixed(1)} kg', colors),
              _chip('💪 ${measurement.muscleMassKg.toStringAsFixed(1)} kg ${l10n.muscleMass.toLowerCase()}', colors),
              _chip('🔥 ${measurement.bodyFatPercentage.toStringAsFixed(1)} % ${l10n.bodyFat.toLowerCase()}', colors),
              if (measurement.bodyWaterPercentage != null)
                _chip('💧 ${measurement.bodyWaterPercentage!.toStringAsFixed(1)} % ${l10n.bodyWater.toLowerCase()}', colors),
              if (measurement.visceralFatLevel != null)
                _chip('${l10n.visceralFat} ${measurement.visceralFatLevel}', colors),
              if (measurement.bmr != null)
                _chip('${l10n.bmr} ${measurement.bmr} kcal', colors),
            ],
          ),
          if (measurement.coachNotes != null && measurement.coachNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes_outlined,
                    size: 14, color: colors.subFg),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(measurement.coachNotes!,
                      style: TextStyle(
                          color: colors.subFg, fontSize: 12)),
                ),
              ],
            ),
          ],
          if (measurement.scanPhotoUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_file,
                    size: 14, color: AppColors.primaryColor1),
                const SizedBox(width: 4),
                Text(l10n.scanCount(measurement.scanPhotoUrls.length),
                    style: const TextStyle(
                        color: AppColors.primaryColor1,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            AttachmentsView(urls: measurement.scanPhotoUrls),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, AppThemeColors colors) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: colors.fg)),
      );

  IconData _trendIcon(String? trend) {
    switch (trend) {
      case 'up': return Icons.trending_up;
      case 'down': return Icons.trending_down;
      default: return Icons.trending_flat;
    }
  }

  Color _trendColor(String? trend) {
    switch (trend) {
      case 'up': return AppColors.successColor;
      case 'down': return AppColors.errorColor;
      default: return AppColors.grayColor;
    }
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_weight_outlined,
              size: 72, color: AppColors.primaryColor1.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(l10n.noMeasurementsYet,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.fg)),
          const SizedBox(height: 8),
          Text(l10n.noMeasurementsHint,
              style: TextStyle(fontSize: 14, color: colors.subFg)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.addMeasurement),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor1,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(String iso) {
  try {
    final d = DateTime.parse(iso);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  } catch (_) {
    return iso.length > 10 ? iso.substring(0, 10) : iso;
  }
}
