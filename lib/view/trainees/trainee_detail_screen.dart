import 'package:fitnessapp/common_widgets/attachments_view.dart';
import 'package:fitnessapp/common_widgets/user_avatar.dart';
import 'package:fitnessapp/view/workout/workout_templates_screen.dart';
import 'package:fitnessapp/data/models/chat_models.dart';
import 'package:fitnessapp/data/models/membership_models.dart';
import 'package:fitnessapp/data/services/chat_service.dart';
import 'package:fitnessapp/providers/chat_provider.dart';
import 'package:fitnessapp/providers/inbody_provider.dart';
import 'package:fitnessapp/providers/meal_provider.dart';
import 'package:fitnessapp/providers/membership_provider.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/workout_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chat/chat_room_screen.dart';

import '../inbody/add_inbody_screen.dart';
import '../inbody/inbody_history_screen.dart';
import '../progress/progress_body_screen.dart';
import '../workout/workout_day_detail_screen.dart';
import '../../data/models/workout_models.dart';
import '../nutrition/create_meal_plan_screen.dart';
import '../nutrition/build_meal_plan_screen.dart';
import '../nutrition/meal_plan_view_screen.dart';
import '../nutrition/shopping_list_screen.dart';
import '../workout/create_program_screen.dart';
import '../workout/workout_day_session_screen.dart';
import '../workout/workout_history_screen.dart';
import 'subscribe_trainee_screen.dart';

class TraineeDetailScreen extends StatefulWidget {
  static const routeName = '/TraineeDetailScreen';
  final String traineeId;
  final String traineeName;
  final String goal;
  final double heightCm;
  final double currentWeightKg;
  final double? latestBodyScore;
  final String? dietaryRestrictions;
  final String? medicalNotes;
  final int initialTab;

  /// When true (trainee viewing their own details), creation/editing actions
  /// are hidden — the trainee can only view plans, not create them.
  final bool readOnly;

  /// The trainee's USER id (for chat). Distinct from [traineeId] (entity id).
  final String? traineeUserId;
  final String? profileImageUrl;

  // Coach details (shown to the trainee on the Profile tab / used for chat).
  final String? coachUserId;
  final String? coachName;
  final String? coachEmail;
  final String? coachPhoneNumber;
  final String? coachBio;
  final String? coachSpecialization;
  final String? coachImageUrl;

  const TraineeDetailScreen({
    Key? key,
    required this.traineeId,
    required this.traineeName,
    required this.goal,
    required this.heightCm,
    required this.currentWeightKg,
    this.latestBodyScore,
    this.dietaryRestrictions,
    this.medicalNotes,
    this.initialTab = 0,
    this.readOnly = false,
    this.traineeUserId,
    this.profileImageUrl,
    this.coachUserId,
    this.coachName,
    this.coachEmail,
    this.coachPhoneNumber,
    this.coachBio,
    this.coachSpecialization,
    this.coachImageUrl,
  }) : super(key: key);

  @override
  State<TraineeDetailScreen> createState() => _TraineeDetailScreenState();
}

class _TraineeDetailScreenState extends State<TraineeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl =
        TabController(length: 6, vsync: this, initialIndex: widget.initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<MembershipProvider>()
          .loadTraineeMemberships(widget.traineeId);
      context.read<InBodyProvider>().loadHistory(widget.traineeId);
      context.read<WorkoutProvider>().loadActiveProgram(widget.traineeId);
      context.read<MealProvider>().loadActivePlan(widget.traineeId);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Color _goalColor(String goal) {
    switch (goal) {
      case 'Cut':
        return Colors.red.shade400;
      case 'Bulk':
        return Colors.blue.shade400;
      case 'Maintain':
        return Colors.green.shade400;
      default:
        return Colors.orange.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auth = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      extendBody: true,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            backgroundColor: const Color(0xFF1C1714),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1C1714), Color(0xFF2A221E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      UserAvatar(
                        imageUrl: widget.profileImageUrl,
                        name: widget.traineeName,
                        radius: 36,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        foregroundColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.traineeName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _goalColor(widget.goal)
                                  .withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _goalColor(widget.goal), width: 1.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag_outlined,
                                    size: 13, color: _goalColor(widget.goal)),
                                const SizedBox(width: 4),
                                Text(
                                  widget.goal,
                                  style: TextStyle(
                                      color: _goalColor(widget.goal),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon:
                    const Icon(Icons.chat_bubble_rounded, color: Colors.white),
                tooltip: 'Open chat',
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  final user = auth.currentUser;
                  if (user == null) return;
                  final isStaff = auth.isCoach || auth.isGymAdmin;

                  // Conversation is always keyed by (coachUserId, traineeUserId).
                  final coachUserId =
                      isStaff ? user.userId : (widget.coachUserId ?? '');
                  final traineeUserId =
                      isStaff ? (widget.traineeUserId ?? '') : user.userId;
                  if (coachUserId.isEmpty || traineeUserId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Chat is not available for this user.')));
                    return;
                  }
                  final coachName =
                      isStaff ? user.fullName : (widget.coachName ?? 'Coach');
                  final traineeName =
                      isStaff ? widget.traineeName : user.fullName;

                  final cId = ChatService.convId(coachUserId, traineeUserId);
                  await context.read<ChatProvider>().openOrCreateConversation(
                        coachId: coachUserId,
                        traineeId: traineeUserId,
                        coachName: coachName,
                        traineeName: traineeName,
                        gymId: user.gymId,
                      );
                  if (!context.mounted) return;
                  Navigator.pushNamed(
                    context,
                    ChatRoomScreen.routeName,
                    arguments: ChatConversation(
                      id: cId,
                      coachId: coachUserId,
                      traineeId: traineeUserId,
                      coachName: coachName,
                      traineeName: traineeName,
                      gymId: user.gymId,
                      lastMessage: '',
                      lastMessageAt: DateTime.now(),
                      unreadCoach: 0,
                      unreadTrainee: 0,
                    ),
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tabs: [
                    Tab(
                        icon: const Icon(Icons.person_outline, size: 18),
                        text: l10n.profile),
                    Tab(
                        icon: const Icon(Icons.card_membership_outlined,
                            size: 18),
                        text: l10n.membership),
                    Tab(
                        icon:
                            const Icon(Icons.monitor_weight_outlined, size: 18),
                        text: l10n.inBody),
                    Tab(
                        icon:
                            const Icon(Icons.fitness_center_outlined, size: 18),
                        text: l10n.workout),
                    Tab(
                        icon: const Icon(Icons.restaurant_outlined, size: 18),
                        text: l10n.nutrition),
                    Tab(
                        icon:
                            const Icon(Icons.photo_library_outlined, size: 18),
                        text: l10n.progressBody),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _ProfileTab(widget: widget),
            _MembershipTab(
              traineeId: widget.traineeId,
              gymId: auth.currentUser?.gymId ?? '',
              readOnly: widget.readOnly,
            ),
            _InBodyTab(
              traineeId: widget.traineeId,
              traineeName: widget.traineeName,
              readOnly: widget.readOnly,
            ),
            _WorkoutTab(
              traineeId: widget.traineeId,
              traineeName: widget.traineeName,
              readOnly: widget.readOnly,
            ),
            _NutritionTab(
              traineeId: widget.traineeId,
              traineeName: widget.traineeName,
              readOnly: widget.readOnly,
            ),
            ProgressBodyScreen(
              traineeId: widget.traineeId,
              traineeName: widget.traineeName,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final TraineeDetailScreen widget;
  const _ProfileTab({required this.widget});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 90),
      child: Column(
        children: [
          // Stats row
          Row(
            children: [
              _StatBox(
                  label: AppLocalizations.of(context).heightCm,
                  value: '${widget.heightCm.toStringAsFixed(0)} cm'),
              const SizedBox(width: 12),
              _StatBox(
                  label: AppLocalizations.of(context).weight,
                  value: '${widget.currentWeightKg.toStringAsFixed(1)} kg'),
              const SizedBox(width: 12),
              _StatBox(
                  label: AppLocalizations.of(context).bodyScore,
                  value: widget.latestBodyScore != null
                      ? widget.latestBodyScore!.toStringAsFixed(0)
                      : '—'),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.dietaryRestrictions != null &&
              widget.dietaryRestrictions!.isNotEmpty)
            _InfoCard(
              icon: Icons.no_food_outlined,
              title: AppLocalizations.of(context).dietaryRestrictions,
              body: widget.dietaryRestrictions!,
            ),
          if (widget.medicalNotes != null && widget.medicalNotes!.isNotEmpty)
            _InfoCard(
              icon: Icons.medical_information_outlined,
              title: AppLocalizations.of(context).medicalNotes,
              body: widget.medicalNotes!,
            ),

          // ── Your Coach (shown to the trainee) ──────────────────────────
          if (widget.coachName != null && widget.coachName!.trim().isNotEmpty)
            _CoachCard(
              name: widget.coachName!.trim(),
              email: widget.coachEmail,
              phone: widget.coachPhoneNumber,
              bio: widget.coachBio,
              specialization: widget.coachSpecialization,
              imageUrl: widget.coachImageUrl,
            ),
        ],
      ),
    );
  }
}

// ── Coach card ────────────────────────────────────────────────────────────────
class _CoachCard extends StatelessWidget {
  final String name;
  final String? email;
  final String? phone;
  final String? bio;
  final String? specialization;
  final String? imageUrl;
  const _CoachCard({
    required this.name,
    this.email,
    this.phone,
    this.bio,
    this.specialization,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: 4),
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
              const Icon(Icons.sports_gymnastics_rounded,
                  size: 18, color: AppColors.primaryColor1),
              const SizedBox(width: 8),
              Text('Your Coach',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colors.fg)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              UserAvatar(
                imageUrl: imageUrl,
                name: name,
                radius: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: colors.fg)),
                    if (specialization != null &&
                        specialization!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(specialization!.trim(),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.primaryColor1)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (bio != null && bio!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(bio!.trim(),
                style:
                    TextStyle(fontSize: 13, height: 1.4, color: colors.subFg)),
          ],
          if (email != null && email!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _CoachContactRow(icon: Icons.email_outlined, value: email!.trim()),
          ],
          if (phone != null && phone!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _CoachContactRow(icon: Icons.phone_outlined, value: phone!.trim()),
          ],
        ],
      ),
    );
  }
}

class _CoachContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _CoachContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 15, color: colors.mutedFg),
        const SizedBox(width: 8),
        Expanded(
          child:
              Text(value, style: TextStyle(fontSize: 13, color: colors.subFg)),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.listTile,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.primaryColor1)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: colors.subFg)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _InfoCard(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryColor1, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colors.fg)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: colors.subFg, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Membership Tab ────────────────────────────────────────────────────────────
class _MembershipTab extends StatelessWidget {
  final String traineeId;
  final String gymId;
  final bool readOnly;
  const _MembershipTab(
      {required this.traineeId, required this.gymId, this.readOnly = false});

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Expired':
        return Colors.red;
      case 'Frozen':
        return Colors.blue;
      case 'Cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<MembershipProvider>();

    return RefreshIndicator(
      onRefresh: () => provider.loadTraineeMemberships(traineeId),
      child: provider.loadingMemberships
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Coach/Admin: assign a plan to the trainee. The trainee pays
                // the coach (cash) — no system "Subscribe & Pay" here.
                if (!readOnly)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubscribeTraineeScreen(
                                traineeId: traineeId, gymId: gymId),
                          ),
                        ).then(
                            (_) => provider.loadTraineeMemberships(traineeId)),
                        icon: const Icon(Icons.add),
                        label:
                            Text(AppLocalizations.of(context).subscribeToPlan),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor1,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  )
                else
                  const SliverPadding(padding: EdgeInsets.only(top: 8)),
                if (provider.traineeMemberships.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(AppLocalizations.of(context).noMembershipsYet,
                          style: TextStyle(color: colors.subFg)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final m = provider.traineeMemberships[i];
                          return _MembershipCard(
                            membership: m,
                            statusColor: _statusColor(m.status),
                            readOnly: readOnly,
                            onAction: (action) async {
                              if (action == 'renew') {
                                await provider.renew(m.id,
                                    traineeId: traineeId);
                              } else {
                                await provider.updateStatus(m.id, action,
                                    traineeId: traineeId);
                              }
                            },
                          );
                        },
                        childCount: provider.traineeMemberships.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final TraineeMembershipModel membership;
  final Color statusColor;
  final void Function(String action) onAction;
  final bool readOnly;

  const _MembershipCard({
    required this.membership,
    required this.statusColor,
    required this.onAction,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(16),
        border: membership.isExpiring
            ? Border.all(color: AppColors.warningColor, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(membership.planName,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: colors.fg)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(membership.status,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${membership.startDate.toString().substring(0, 10)} → ${membership.endDate.toString().substring(0, 10)}',
            style: TextStyle(color: colors.subFg, fontSize: 12),
          ),
          Text('EGP ${membership.price.toStringAsFixed(0)} ${l10n.perPlan}',
              style: const TextStyle(
                  color: AppColors.primaryColor1,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          if (membership.isExpiring)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l10n.expiringWarning,
                  style: const TextStyle(
                      color: AppColors.warningColor, fontSize: 12)),
            ),
          // Action buttons — coach/admin only (trainee view is read-only).
          if (!readOnly) ...[
            const SizedBox(height: 12),
            if (membership.isActive)
              Row(
                children: [
                  _ActionBtn(
                      label: l10n.renew,
                      color: Colors.green,
                      onTap: () => onAction('renew')),
                  const SizedBox(width: 8),
                  _ActionBtn(
                      label: l10n.freeze,
                      color: Colors.blue,
                      onTap: () => onAction('Frozen')),
                  const SizedBox(width: 8),
                  _ActionBtn(
                      label: l10n.cancel,
                      color: Colors.red,
                      onTap: () => onAction('Cancelled')),
                ],
              )
            else if (membership.status == 'Frozen')
              _ActionBtn(
                  label: l10n.unfreeze,
                  color: Colors.green,
                  onTap: () => onAction('Active')),
          ],
          // Cash-payment schedule — coach marks each period Paid/Unpaid.
          if (membership.status != 'Cancelled')
            _PaymentSchedule(
              membershipId: membership.id,
              billingCycle: membership.billingCycle,
              readOnly: readOnly,
            ),
        ],
      ),
    );
  }
}

/// Lists a membership's payable periods. Coach can toggle Paid/Unpaid (cash
/// collected); the trainee sees them read-only.
class _PaymentSchedule extends StatefulWidget {
  final String membershipId;
  final String billingCycle;
  final bool readOnly;
  const _PaymentSchedule({
    required this.membershipId,
    required this.billingCycle,
    required this.readOnly,
  });

  @override
  State<_PaymentSchedule> createState() => _PaymentScheduleState();
}

class _PaymentScheduleState extends State<_PaymentSchedule> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MembershipProvider>().loadPayments(widget.membershipId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<MembershipProvider>();
    final payments = provider.paymentsFor(widget.membershipId);
    final loading = provider.isLoadingPayments(widget.membershipId);

    if (loading && payments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
              width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    if (payments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Divider(color: colors.divider, height: 1),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.payments_rounded, size: 16, color: colors.subFg),
            const SizedBox(width: 6),
            Text('Cash payments · ${widget.billingCycle}',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13, color: colors.fg)),
          ],
        ),
        const SizedBox(height: 10),
        ...payments.map((p) => _row(context, colors, p)),
        // Server-side pagination: load the next page on demand.
        if (provider.paymentsHasMore(widget.membershipId))
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: loading
                  ? null
                  : () => context
                      .read<MembershipProvider>()
                      .loadMorePayments(widget.membershipId),
              icon: loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.expand_more_rounded, size: 18),
              label: const Text('Show more',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor1),
            ),
          ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Free':
        return Colors.blue;
      default:
        return Colors.orange; // Unpaid
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icons.check_circle_rounded;
      case 'Free':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  Future<void> _setStatus(BuildContext context, String paymentId, String status) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context
        .read<MembershipProvider>()
        .setPaymentStatus(widget.membershipId, paymentId, status);
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Could not update payment status.'),
          backgroundColor: AppColors.errorColor));
    }
  }

  Widget _row(BuildContext context, dynamic colors, MembershipPaymentModel p) {
    final color = _statusColor(p.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: p.isCurrent
            ? Border.all(color: AppColors.primaryColor1.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Text('${p.sequenceNumber}',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_d(p.periodStart)} → ${_d(p.periodEnd)}',
                    style: TextStyle(
                        fontSize: 12,
                        color: colors.fg,
                        fontWeight: FontWeight.w600)),
                Text(
                    '${p.isFree ? 'Free' : 'EGP ${p.amount.toStringAsFixed(0)}'}'
                    '${p.isCurrent ? '  ·  current' : ''}',
                    style: TextStyle(fontSize: 11, color: colors.subFg)),
              ],
            ),
          ),
          if (widget.readOnly)
            _chip(p.status, color, false)
          else
            // Coach: tap to set Paid / Unpaid / Free.
            PopupMenuButton<String>(
              onSelected: (s) => _setStatus(context, p.id, s),
              itemBuilder: (_) => [
                _menuItem('Paid', Icons.check_circle_rounded, Colors.green),
                _menuItem('Unpaid', Icons.schedule_rounded, Colors.orange),
                _menuItem('Free', Icons.card_giftcard_rounded, Colors.blue),
              ],
              child: _chip(p.status, color, true),
            ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, Color color) =>
      PopupMenuItem<String>(
        value: value,
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(value),
        ]),
      );

  Widget _chip(String status, Color color, bool tappable) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: tappable ? Border.all(color: color.withValues(alpha: 0.6)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_statusIcon(status), size: 14, color: color),
            const SizedBox(width: 4),
            Text(status,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 11)),
            if (tappable) ...[
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 14, color: color.withValues(alpha: 0.7)),
            ],
          ],
        ),
      );

  String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString().substring(2)}';
}

// ── InBody Tab ────────────────────────────────────────────────────────────────
class _InBodyTab extends StatelessWidget {
  final String traineeId;
  final String traineeName;
  final bool readOnly;
  const _InBodyTab(
      {required this.traineeId,
      required this.traineeName,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<InBodyProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_weight_outlined,
                size: 64,
                color: AppColors.primaryColor1.withValues(alpha: 0.35)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).noInBodyYet,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.fg)),
            // InBody can be added by both the coach and the trainee.
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final provider = context.read<InBodyProvider>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddInBodyScreen(
                        traineeId: traineeId, traineeName: traineeName),
                  ),
                ).then((_) => provider.loadHistory(traineeId));
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).addMeasurement),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor1,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      );
    }

    // Show summary + "View All" button
    final latest = provider.latest!;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latest score card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryColor1, AppColors.primaryColor2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: latest.bodyScore / 100,
                        strokeWidth: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Text(latest.bodyScore.toStringAsFixed(0),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).latestBodyScore,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(
                          '${latest.weightKg.toStringAsFixed(1)} kg  |  '
                          '${latest.muscleMassKg.toStringAsFixed(1)} kg muscle  |  '
                          '${latest.bodyFatPercentage.toStringAsFixed(1)} % fat',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(_fmtDate(latest.recordedAt),
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final provider = context.read<InBodyProvider>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InBodyHistoryScreen(
                            traineeId: traineeId, traineeName: traineeName),
                      ),
                    ).then((_) => provider.loadHistory(traineeId));
                  },
                  icon: const Icon(Icons.history),
                  label: Text(
                      '${AppLocalizations.of(context).viewAll} (${provider.history.length})'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor1,
                    side: const BorderSide(color: AppColors.primaryColor1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 46),
                  ),
                ),
              ),
              // InBody can be added by both the coach and the trainee.
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final provider = context.read<InBodyProvider>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddInBodyScreen(
                            traineeId: traineeId, traineeName: traineeName),
                      ),
                    ).then((_) => provider.loadHistory(traineeId));
                  },
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context).add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).recentMeasurements,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15, color: colors.fg)),
          const SizedBox(height: 12),
          ...provider.history.take(3).map((m) => _MiniCard(m)).toList(),
        ],
      ),
    );
  }

  String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso.length > 10 ? iso.substring(0, 10) : iso;
    }
  }
}

class _MiniCard extends StatelessWidget {
  final dynamic m;
  const _MiniCard(this.m);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${m.weightKg.toStringAsFixed(1)} kg  ·  '
                  '${m.muscleMassKg.toStringAsFixed(1)} kg muscle  ·  '
                  '${m.bodyFatPercentage.toStringAsFixed(1)} % fat',
                  style: TextStyle(fontSize: 12, color: colors.fg),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Score ${m.bodyScore.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: AppColors.primaryColor1,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ),
          if ((m.scanPhotoUrls as List).isNotEmpty)
            AttachmentsView(urls: List<String>.from(m.scanPhotoUrls)),
        ],
      ),
    );
  }
}

// ── Workout Tab ───────────────────────────────────────────────────────────────
class _WorkoutTab extends StatelessWidget {
  final String traineeId;
  final String traineeName;
  final bool readOnly;
  const _WorkoutTab(
      {required this.traineeId,
      required this.traineeName,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<WorkoutProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final program = provider.currentProgram;

    return RefreshIndicator(
      onRefresh: () =>
          context.read<WorkoutProvider>().loadActiveProgram(traineeId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).padding.bottom + 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Actions ───────────────────────────────────────────────
            if (!readOnly) ...[
              // Primary hero action — create a program from scratch.
              _HeroActionButton(
                icon: Icons.add_rounded,
                label: program == null
                    ? AppLocalizations.of(context).createProgram
                    : AppLocalizations.of(context).newProgramLabel,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateProgramScreen(
                      traineeId: traineeId,
                      traineeName: traineeName,
                    ),
                  ),
                ).then((_) => context
                    .read<WorkoutProvider>()
                    .loadActiveProgram(traineeId)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _WorkoutActionChip(
                      icon: Icons.bolt_rounded,
                      label: AppLocalizations.of(context).assignFromTemplate,
                      color: const Color(0xFF6366F1),
                      onTap: () => _assignFromTemplate(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WorkoutActionChip(
                      icon: Icons.dashboard_customize_rounded,
                      label: AppLocalizations.of(context).workoutTemplates,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WorkoutTemplatesScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WorkoutActionChip(
                      icon: Icons.history_rounded,
                      label: AppLocalizations.of(context).historyLabel,
                      color: AppColors.primaryColor1,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutHistoryScreen(
                            traineeId: traineeId,
                            traineeName: traineeName,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Trainee: just history.
              _WorkoutActionChip(
                icon: Icons.history_rounded,
                label: AppLocalizations.of(context).historyLabel,
                color: AppColors.primaryColor1,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutHistoryScreen(
                      traineeId: traineeId,
                      traineeName: traineeName,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            if (program == null) ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.fitness_center_outlined,
                        size: 60,
                        color: AppColors.primaryColor1.withValues(alpha: 0.35)),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context).noActiveProgram,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.fg)),
                    const SizedBox(height: 6),
                    Text(
                        readOnly
                            ? 'Your coach hasn\'t added a workout program yet.'
                            : AppLocalizations.of(context).createWorkoutHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: colors.subFg)),
                  ],
                ),
              ),
            ] else ...[
              // Program header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryColor1, AppColors.primaryColor2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fitness_center,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(program.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                          Text(
                              '${program.periodType}  ·  '
                              '${program.days.length} day(s)',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text(
                              '${_fmtDate(program.startDate)} → ${_fmtDate(program.endDate)}',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // File-based workout (auto-detected): show the attachment.
              if (program.attachmentUrl != null &&
                  program.attachmentUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                AttachmentsView(urls: [program.attachmentUrl!]),
              ],
              if (program.days.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).daysLabel,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: colors.fg)),
                const SizedBox(height: 10),
              ],
              ...program.days.map((day) => _WorkoutDayCard(
                    day: day,
                    traineeId: traineeId,
                    programId: program.id,
                    onLog: () => context
                        .read<WorkoutProvider>()
                        .loadActiveProgram(traineeId),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso.length > 10 ? iso.substring(0, 10) : iso;
    }
  }

  /// Let the coach pick one of their templates and assign it to this trainee.
  Future<void> _assignFromTemplate(BuildContext context) async {
    final provider = context.read<WorkoutProvider>();
    final messenger = ScaffoldMessenger.of(context);
    await provider.loadTemplates();
    if (!context.mounted) return;
    final templates = provider.templates;
    if (templates.isEmpty) {
      messenger.showSnackBar(const SnackBar(
          content: Text(
              'No templates yet. Create one from the sidebar → Workout Templates.')));
      return;
    }

    final colors = context.colors;
    final selected = await showModalBottomSheet<WorkoutTemplate>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Choose a template',
                  style: TextStyle(
                      color: colors.fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: templates
                    .map((t) => ListTile(
                          leading: Icon(
                              t.isFile
                                  ? Icons.description_rounded
                                  : Icons.fitness_center_rounded,
                              color: AppColors.primaryColor1),
                          title: Text(t.name,
                              style: TextStyle(color: colors.fg)),
                          subtitle: Text(
                              t.isFile
                                  ? 'File workout · ${t.periodType}'
                                  : '${t.dayCount} day(s) · ${t.periodType}',
                              style:
                                  TextStyle(color: colors.subFg, fontSize: 12)),
                          onTap: () => Navigator.pop(context, t),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null || !context.mounted) return;

    final ok = await provider.assignTemplate(selected.id, traineeId);
    if (!context.mounted) return;
    if (ok) {
      await provider.loadActiveProgram(traineeId);
      messenger.showSnackBar(SnackBar(
          content: Text('Assigned "${selected.name}"'),
          backgroundColor: AppColors.successColor));
    } else {
      messenger.showSnackBar(const SnackBar(
          content: Text('Could not assign the template')));
    }
  }
}

// ── Workout action widgets ────────────────────────────────────────────────────
class _HeroActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HeroActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryColor1, AppColors.primaryColor2],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor1.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _WorkoutActionChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 11.5,
                      height: 1.2,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutDayCard extends StatelessWidget {
  final dynamic day;
  final String traineeId;
  final String programId;
  final VoidCallback onLog;
  const _WorkoutDayCard(
      {required this.day,
      required this.traineeId,
      required this.programId,
      required this.onLog});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final commentCount = (day.exercises as List)
        .fold<int>(0, (acc, ex) => acc + (ex.comments as List).length);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutDayDetailScreen(
            day: day as WorkoutDay,
            traineeId: traineeId,
            programId: programId,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.listTile,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor1.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('${day.dayNumber}',
                        style: const TextStyle(
                            color: AppColors.primaryColor1,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day.dayName,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: colors.fg)),
                      Text(
                          '${day.muscleGroupFocus}  ·  ${day.exercises.length} exercises',
                          style: TextStyle(fontSize: 12, color: colors.subFg)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutDaySessionScreen(
                        day: day,
                        traineeId: traineeId,
                      ),
                    ),
                  ).then((_) => onLog()),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor1),
                  child: Text(AppLocalizations.of(context).logLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            if ((day.exercises as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (day.exercises as List)
                    .take(4)
                    .map<Widget>((ex) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(ex.exerciseNameEn,
                              style: TextStyle(fontSize: 11, color: colors.fg)),
                        ))
                    .toList()
                  ..addAll(
                    (day.exercises as List).length > 4
                        ? [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor1
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                  '+${(day.exercises as List).length - 4} ${AppLocalizations.of(context).more}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primaryColor1,
                                      fontWeight: FontWeight.w600)),
                            )
                          ]
                        : [],
                  ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.comment_rounded,
                    size: 13, color: AppColors.primaryColor1),
                const SizedBox(width: 4),
                Text(
                    commentCount > 0
                        ? '$commentCount ${AppLocalizations.of(context).coachComments}'
                        : AppLocalizations.of(context).coachComments,
                    style: TextStyle(
                        fontSize: 11,
                        color: colors.subFg,
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: colors.mutedFg),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nutrition Tab ─────────────────────────────────────────────────────────────
class _NutritionTab extends StatelessWidget {
  final String traineeId;
  final String traineeName;
  final bool readOnly;
  const _NutritionTab(
      {required this.traineeId,
      required this.traineeName,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<MealProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final plan = provider.currentPlan;

    return RefreshIndicator(
      onRefresh: () => context.read<MealProvider>().loadActivePlan(traineeId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).padding.bottom + 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action row
            if (!readOnly || plan != null)
              Row(
                children: [
                  if (!readOnly) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateMealPlanScreen(
                              traineeId: traineeId,
                              traineeName: traineeName,
                            ),
                          ),
                        ).then((_) => context
                            .read<MealProvider>()
                            .loadActivePlan(traineeId)),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(plan == null
                            ? AppLocalizations.of(context).createPlan
                            : AppLocalizations.of(context).newPlan),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor1,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(0, 44),
                        ),
                      ),
                    ),
                  ],
                  if (plan != null) ...[
                    if (!readOnly) ...[
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BuildMealPlanScreen(
                                planId: plan.id, traineeName: traineeName),
                          ),
                        ).then((_) => context
                            .read<MealProvider>()
                            .loadActivePlan(traineeId)),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(AppLocalizations.of(context).edit),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor1,
                          side:
                              const BorderSide(color: AppColors.primaryColor1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(0, 44),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShoppingListScreen(planId: plan.id),
                          ),
                        ),
                        icon:
                            const Icon(Icons.shopping_cart_outlined, size: 16),
                        label: Text(AppLocalizations.of(context).shop),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor1,
                          side:
                              const BorderSide(color: AppColors.primaryColor1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(0, 44),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            if (!readOnly || plan != null) const SizedBox(height: 20),

            if (plan == null) ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu_outlined,
                        size: 60,
                        color: AppColors.primaryColor1.withValues(alpha: 0.35)),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context).noActiveMealPlan,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.fg)),
                    const SizedBox(height: 6),
                    Text(
                        readOnly
                            ? 'Your coach hasn\'t added a meal plan yet.'
                            : AppLocalizations.of(context).createNutritionHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: colors.subFg)),
                  ],
                ),
              ),
            ] else ...[
              // Plan header card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.restaurant_menu,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(plan.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Macro targets row
                    Row(
                      children: [
                        _MacroTarget(AppLocalizations.of(context).calories,
                            '${plan.targetCalories}', 'kcal', Colors.orange),
                        _MacroTarget(AppLocalizations.of(context).protein,
                            '${plan.targetProteinGrams}', 'g', Colors.red),
                        _MacroTarget(AppLocalizations.of(context).carbs,
                            '${plan.targetCarbsGrams}', 'g', Colors.blue),
                        _MacroTarget(AppLocalizations.of(context).fat,
                            '${plan.targetFatGrams}', 'g', Colors.yellow),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Day summaries
              Text(AppLocalizations.of(context).thisWeek,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: colors.fg)),
              const SizedBox(height: 10),
              ...plan.days.map((day) => _NutritionDayRow(day: day)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MealPlanViewScreen(plan: plan, traineeId: traineeId),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(AppLocalizations.of(context).traineeView),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor1,
                    side: const BorderSide(color: AppColors.primaryColor1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroTarget extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _MacroTarget(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: value,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  TextSpan(
                      text: unit,
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _NutritionDayRow extends StatelessWidget {
  final dynamic day;
  const _NutritionDayRow({required this.day});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                day.dayName.substring(0, 3),
                style: const TextStyle(
                    color: Color(0xFF43A047),
                    fontWeight: FontWeight.w800,
                    fontSize: 11),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(day.dayName,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colors.fg)),
          ),
          if ((day.meals as List).isEmpty)
            Text(AppLocalizations.of(context).noMeals,
                style: TextStyle(fontSize: 11, color: colors.subFg))
          else ...[
            _MacroChip('🔥 ${day.totalCalories.toStringAsFixed(0)}'),
            const SizedBox(width: 4),
            _MacroChip('🥩 ${day.totalProtein.toStringAsFixed(0)}g'),
          ],
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String text;
  const _MacroChip(this.text);
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: colors.fg)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    );
  }
}
