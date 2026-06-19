import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/gym_admin_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Gym Admin: trainees who haven't paid the current period.
class UnpaidTraineesScreen extends StatefulWidget {
  static const routeName = '/UnpaidTraineesScreen';
  const UnpaidTraineesScreen({Key? key}) : super(key: key);

  @override
  State<UnpaidTraineesScreen> createState() => _UnpaidTraineesScreenState();
}

class _UnpaidTraineesScreenState extends State<UnpaidTraineesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<GymAdminProvider>().loadUnpaidTrainees());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<GymAdminProvider>();
    final list = provider.unpaidTrainees;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text(l10n.unpaidTrainees,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: provider.unpaidLoading && list.isEmpty
          ? const LiaqhPageLoader()
          : list.isEmpty
              ? Center(
                  child: Text(l10n.everyonePaid,
                      style: TextStyle(color: colors.subFg)))
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<GymAdminProvider>().loadUnpaidTrainees(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final t = list[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.errorColor.withValues(alpha: 0.25)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                AppColors.errorColor.withValues(alpha: 0.12),
                            child: Text(
                                t.fullName.isNotEmpty
                                    ? t.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: AppColors.errorColor,
                                    fontWeight: FontWeight.w700)),
                          ),
                          title: Text(t.fullName,
                              style: TextStyle(
                                  color: colors.fg,
                                  fontWeight: FontWeight.w700)),
                          subtitle: Text(
                              '${t.email}\n${l10n.coachWithName(t.coachName)}',
                              style: TextStyle(
                                  color: colors.subFg, fontSize: 12)),
                          isThreeLine: true,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.errorColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(l10n.unpaid,
                                style: const TextStyle(
                                    color: AppColors.errorColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
