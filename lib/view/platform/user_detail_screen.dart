import 'package:fitnessapp/data/models/platform_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/platform_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'platform_widgets.dart';

class UserDetailScreen extends StatefulWidget {
  static const routeName = '/UserDetailScreen';
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatformProvider>().loadUserDetail(widget.userId);
    });
  }

  void _load() =>
      context.read<PlatformProvider>().loadUserDetail(widget.userId);

  Color _roleColor(String role) {
    switch (role) {
      case 'GymAdmin':
        return const Color(0xFFF59E0B);
      case 'Coach':
        return const Color(0xFF8B5CF6);
      case 'Trainee':
        return const Color(0xFF3B82F6);
      default:
        return AppColors.primaryColor1;
    }
  }

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = context.watch<PlatformProvider>();
    final u = p.userDetail;

    return Scaffold(
      backgroundColor: colors.bg,
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PlatformGradientHeader(
                title: u?.fullName ?? 'User',
                subtitle: u?.role ?? 'Loading...',
                icon: Icons.person_rounded,
                showBack: true,
              ),
            ),
            if (p.userDetailLoading && u == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: const LiaqhPageLoader(),
              )
            else if (p.userDetailError != null && u == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformErrorState(
                    message: p.userDetailError!, onRetry: _load),
              )
            else if (u != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _profileCard(u),
                    const SizedBox(height: 16),
                    _infoCard(u),
                    if (u.role == 'Coach') ...[
                      const SizedBox(height: 20),
                      const PlatformSectionTitle('Coach Details'),
                      const SizedBox(height: 10),
                      _coachCard(u),
                    ],
                    if (u.role == 'Trainee') ...[
                      const SizedBox(height: 20),
                      const PlatformSectionTitle('Trainee Details'),
                      const SizedBox(height: 10),
                      _traineeCard(u),
                    ],
                    const SizedBox(height: 20),
                    _statusButton(u),
                  ]),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(UserDetail u) {
    final colors = context.colors;
    final rc = _roleColor(u.role);
    return PlatformCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: rc.withValues(alpha: 0.15),
            backgroundImage:
                (u.profileImageUrl != null && u.profileImageUrl!.isNotEmpty)
                    ? NetworkImage(u.profileImageUrl!)
                    : null,
            child: (u.profileImageUrl == null || u.profileImageUrl!.isEmpty)
                ? Text(
                    u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: rc,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.fullName,
                    style: TextStyle(
                        color: colors.fg,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: rc.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(u.role,
                          style: TextStyle(
                              color: rc,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    PlatformStatusChip(active: u.isActive),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(UserDetail u) {
    return PlatformCard(
      child: Column(
        children: [
          _infoRow('Email', u.email),
          if (u.phoneNumber != null && u.phoneNumber!.isNotEmpty)
            _infoRow('Phone', u.phoneNumber!),
          if (u.gymName.isNotEmpty) _infoRow('Gym', u.gymName),
          if (u.preferredLanguage.isNotEmpty)
            _infoRow('Language', u.preferredLanguage),
          if (u.createdAt != null) _infoRow('Joined', _date(u.createdAt!)),
        ],
      ),
    );
  }

  Widget _coachCard(UserDetail u) {
    return PlatformCard(
      child: Column(
        children: [
          _infoRow('Trainees',
              '${u.coachTraineeCount ?? 0} / ${u.coachTraineeLimit ?? 0}'),
          if (u.coachBio != null && u.coachBio!.isNotEmpty)
            _infoRow('Bio', u.coachBio!),
        ],
      ),
    );
  }

  Widget _traineeCard(UserDetail u) {
    return PlatformCard(
      child: Column(
        children: [
          if (u.traineeCoachName != null && u.traineeCoachName!.isNotEmpty)
            _infoRow('Coach', u.traineeCoachName!),
          if (u.traineeGoal != null && u.traineeGoal!.isNotEmpty)
            _infoRow('Goal', u.traineeGoal!),
          if (u.traineeHeightCm != null)
            _infoRow('Height', '${u.traineeHeightCm!.toStringAsFixed(0)} cm'),
          if (u.traineeCurrentWeightKg != null)
            _infoRow('Weight',
                '${u.traineeCurrentWeightKg!.toStringAsFixed(1)} kg'),
          if (u.traineeMembershipStatus != null &&
              u.traineeMembershipStatus!.isNotEmpty)
            _infoRow('Membership', u.traineeMembershipStatus!),
          if (u.traineeMembershipEnd != null)
            _infoRow('Membership ends', _date(u.traineeMembershipEnd!)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(color: colors.subFg, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(UserDetail u) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _confirmToggle(u),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              u.isActive ? AppColors.errorColor : AppColors.successColor,
          minimumSize: const Size(0, 50),
        ),
        icon: Icon(
            u.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
            size: 20),
        label: Text(u.isActive ? 'Deactivate User' : 'Activate User',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Future<void> _confirmToggle(UserDetail u) async {
    final deactivate = u.isActive;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(deactivate ? 'Deactivate User' : 'Activate User'),
        content: Text(deactivate
            ? 'Are you sure you want to deactivate ${u.fullName}?'
            : 'Are you sure you want to activate ${u.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: deactivate
                  ? AppColors.errorColor
                  : AppColors.successColor,
            ),
            child: Text(deactivate ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context
          .read<PlatformProvider>()
          .setUserStatus(u.id, !u.isActive);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }
}
