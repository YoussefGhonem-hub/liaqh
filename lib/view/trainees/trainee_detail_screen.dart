import 'package:fitnessapp/common_widgets/attachments_view.dart';
import 'package:fitnessapp/view/coaching/coach_profile_view_screen.dart';
import 'package:fitnessapp/view/reports/trainee_report_screen.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
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
import 'package:fitnessapp/utils/nutrition_l10n.dart';
import 'package:fitnessapp/utils/status_l10n.dart';
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
import '../workout/build_workout_day_screen.dart';
import 'package:fitnessapp/providers/daily_workout_log_provider.dart';
import 'package:fitnessapp/providers/coaching_provider.dart';
import 'package:fitnessapp/data/models/coaching_models.dart';
import 'package:fitnessapp/data/services/notification_service.dart';
import 'package:confetti/confetti.dart';
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

/// Chat icon that gently pulses with a glowing halo to nudge the trainee
/// to message their coach.
class _PulsingChatIcon extends StatefulWidget {
  const _PulsingChatIcon();

  @override
  State<_PulsingChatIcon> createState() => _PulsingChatIconState();
}

class _PulsingChatIconState extends State<_PulsingChatIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD97757)
                    .withValues(alpha: 0.15 + 0.45 * t),
                blurRadius: 6 + 10 * t,
                spreadRadius: 1 + 2 * t,
              ),
            ],
          ),
          child: Transform.scale(
            scale: 1.0 + 0.12 * t,
            child: child,
          ),
        );
      },
      child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
    );
  }
}

class _TraineeDetailScreenState extends State<TraineeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl =
        TabController(length: 7, vsync: this, initialIndex: widget.initialTab);
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
            iconTheme: const IconThemeData(color: Colors.white),
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
                                  goalLabel(
                                      AppLocalizations.of(context), widget.goal),
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
              if (!widget.readOnly)
                IconButton(
                  icon: const Icon(Icons.description_outlined,
                      color: Colors.white),
                  tooltip: 'Generate report',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TraineeReportScreen(
                        traineeId: widget.traineeId,
                        traineeName: widget.traineeName,
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const _PulsingChatIcon(),
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
                        icon: const Icon(Icons.event_available_outlined,
                            size: 18),
                        text: l10n.dailyLog),
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
            _DailyLogTab(
              traineeId: widget.traineeId,
              readOnly: widget.readOnly,
            ),
            _NutritionTab(
              traineeId: widget.traineeId,
              traineeName: widget.traineeName,
              readOnly: widget.readOnly,
              heightCm: widget.heightCm,
              currentWeightKg: widget.currentWeightKg,
              goal: widget.goal,
              traineeUserId: widget.traineeUserId,
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
              coachUserId: widget.coachUserId,
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
  final String? coachUserId;
  const _CoachCard({
    required this.name,
    this.email,
    this.phone,
    this.bio,
    this.specialization,
    this.imageUrl,
    this.coachUserId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
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
              Text(l10n.yourCoach,
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
          if (coachUserId != null && coachUserId!.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CoachProfileViewScreen(coachUserId: coachUserId!),
                  ),
                ),
                icon: const Icon(Icons.badge_outlined,
                    size: 18, color: AppColors.primaryColor1),
                label: Text(l10n.viewProfile,
                    style: const TextStyle(
                        color: AppColors.primaryColor1,
                        fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryColor1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
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
          ? const LiaqhPageLoader()
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
                child: Text(subStatusLabel(l10n, membership.status),
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
          Text('${l10n.currencyEgp} ${membership.price.toStringAsFixed(0)} ${l10n.perPlan}',
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
    final l10n = AppLocalizations.of(context);
    final ok = await context
        .read<MembershipProvider>()
        .setPaymentStatus(widget.membershipId, paymentId, status);
    if (!ok) {
      messenger.showSnackBar(SnackBar(
          content: Text(l10n.couldNotUpdatePaymentStatus),
          backgroundColor: AppColors.errorColor));
    }
  }

  Widget _row(BuildContext context, dynamic colors, MembershipPaymentModel p) {
    final color = _statusColor(p.status);
    final l10n = AppLocalizations.of(context);

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
                    '${p.isFree ? l10n.payStatusFree : '${l10n.currencyEgp} ${p.amount.toStringAsFixed(0)}'}'
                    '${p.isCurrent ? ' · ${l10n.currentPeriodSuffix}' : ''}',
                    style: TextStyle(fontSize: 11, color: colors.subFg)),
              ],
            ),
          ),
          if (widget.readOnly)
            _chip(p.status, payStatusLabel(l10n, p.status), color, false)
          else
            // Coach: tap to set Paid / Unpaid / Free.
            PopupMenuButton<String>(
              onSelected: (s) => _setStatus(context, p.id, s),
              itemBuilder: (_) => [
                _menuItem('Paid', l10n.payStatusPaid, Icons.check_circle_rounded,
                    Colors.green),
                _menuItem('Unpaid', l10n.payStatusUnpaid,
                    Icons.schedule_rounded, Colors.orange),
                _menuItem('Free', l10n.payStatusFree,
                    Icons.card_giftcard_rounded, Colors.blue),
              ],
              child: _chip(p.status, payStatusLabel(l10n, p.status), color, true),
            ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
          String value, String label, IconData icon, Color color) =>
      PopupMenuItem<String>(
        value: value,
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label),
        ]),
      );

  Widget _chip(String status, String label, Color color, bool tappable) =>
      Container(
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
            Text(label,
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
      return const LiaqhPageLoader();
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
      return const LiaqhPageLoader();
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
              // Trainee: just history — full-width button.
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutHistoryScreen(
                        traineeId: traineeId,
                        traineeName: traineeName,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: Text(AppLocalizations.of(context).historyLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor1,
                    side: const BorderSide(color: AppColors.primaryColor1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
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
                            ? AppLocalizations.of(context).coachNoWorkoutYet
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
                    if (!readOnly) ...[
                      // Edit program (manage days)
                      _ProgramIconBtn(
                        icon: Icons.edit_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BuildWorkoutDayScreen(
                              programId: program.id,
                              programName: program.name,
                              traineeId: traineeId,
                              traineeName: traineeName,
                            ),
                          ),
                        ).then((_) => context
                            .read<WorkoutProvider>()
                            .loadActiveProgram(traineeId)),
                      ),
                      const SizedBox(width: 6),
                      // Delete program
                      _ProgramIconBtn(
                        icon: Icons.delete_outline_rounded,
                        onTap: () => _confirmDeleteProgram(
                            context, program.id, program.name),
                      ),
                    ],
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

  /// Confirm + delete the whole program.
  Future<void> _confirmDeleteProgram(
      BuildContext context, String programId, String programName) async {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.deleteProgramTitle,
            style: TextStyle(
                color: colors.fg, fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text(l10n.deleteProgramConfirm(programName),
            style: TextStyle(color: colors.subFg, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final done = await context
        .read<WorkoutProvider>()
        .deleteProgram(programId, traineeId: traineeId);
    messenger.showSnackBar(SnackBar(
      content: Text(done ? l10n.programDeleted : l10n.failedGeneric),
      backgroundColor: done ? AppColors.successColor : AppColors.errorColor,
    ));
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

/// Small translucent icon button used on the program header (edit / delete).
class _ProgramIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ProgramIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 18),
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
                          day.isRestDay == true
                              ? AppLocalizations.of(context).restDay
                              : '${day.muscleGroupFocus}  ·  ${day.exercises.length} exercises',
                          style: TextStyle(
                              fontSize: 12,
                              color: day.isRestDay == true
                                  ? AppColors.primaryColor1
                                  : colors.subFg)),
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

// ── Daily Log Tab ─────────────────────────────────────────────────────────────
class _DailyLogTab extends StatefulWidget {
  final String traineeId;
  final bool readOnly;
  const _DailyLogTab({required this.traineeId, this.readOnly = false});

  @override
  State<_DailyLogTab> createState() => _DailyLogTabState();
}

class _DailyLogTabState extends State<_DailyLogTab> {
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyWorkoutLogProvider>().load(widget.traineeId);
      context.read<CoachingProvider>().loadStats(widget.traineeId);
      if (widget.readOnly) _loadReminder();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _loadReminder() async {
    final r = await NotificationService.getWorkoutReminder();
    if (!mounted) return;
    setState(() {
      _reminderEnabled = r.enabled;
      _reminderTime = TimeOfDay(hour: r.hour, minute: r.minute);
    });
  }

  Future<void> _toggleReminder(bool on) async {
    if (on) {
      await NotificationService.setWorkoutReminder(
          _reminderTime.hour, _reminderTime.minute);
    } else {
      await NotificationService.cancelWorkoutReminder();
    }
    if (mounted) setState(() => _reminderEnabled = on);
  }

  Future<void> _pickReminderTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked == null) return;
    setState(() {
      _reminderTime = picked;
      _reminderEnabled = true;
    });
    await NotificationService.setWorkoutReminder(picked.hour, picked.minute);
  }

  List<DateTime> _currentWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Week starts on Saturday (common in the region): find last Saturday.
    final diff = (today.weekday + 1) % 7; // Sat=6→0, Sun=7→1...
    final start = today.subtract(Duration(days: diff));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  Future<void> _log(DateTime day, bool didWorkout) async {
    final l10n = AppLocalizations.of(context);
    final coaching = context.read<CoachingProvider>();
    final before = coaching.stats;
    final ok =
        await context.read<DailyWorkoutLogProvider>().log(day, didWorkout);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.failedGeneric),
            backgroundColor: AppColors.errorColor),
      );
      return;
    }
    // Refresh stats and celebrate new milestones.
    await coaching.loadStats(widget.traineeId);
    if (!mounted) return;
    final after = coaching.stats;
    const milestones = [7, 30, 100];
    final hitStreak = milestones.contains(after.currentStreak) &&
        after.currentStreak != before.currentStreak;
    final hitGoal = after.thisWeekCount >= after.weeklyGoal &&
        before.thisWeekCount < after.weeklyGoal;
    if (didWorkout && (hitStreak || hitGoal)) {
      _confetti.play();
      final msg = hitStreak
          ? l10n.streakMilestone(after.currentStreak)
          : l10n.weeklyGoalReached;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg), backgroundColor: AppColors.successColor));
    }
  }

  Future<void> _pickWeeklyGoal() async {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final current = context.read<CoachingProvider>().stats.weeklyGoal;
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(l10n.setWeeklyGoal,
                style: TextStyle(color: colors.fg, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...List.generate(7, (i) => i + 1).map((n) => ListTile(
                  title: Text(l10n.daysPerWeek(n),
                      style: TextStyle(color: colors.fg)),
                  trailing: n == current
                      ? const Icon(Icons.check, color: AppColors.primaryColor1)
                      : null,
                  onTap: () => Navigator.pop(ctx, n),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      await context
          .read<CoachingProvider>()
          .setWeeklyGoalAndReload(picked, widget.traineeId);
    }
  }

  String _badgeLabel(AppLocalizations l10n, String b) {
    switch (b) {
      case 'streak_7':
        return l10n.badge7;
      case 'streak_30':
        return l10n.badge30;
      case 'streak_100':
        return l10n.badge100;
      case 'total_10':
        return l10n.badgeTotal10;
      case 'total_50':
        return l10n.badgeTotal50;
      case 'total_100':
        return l10n.badgeTotal100;
      default:
        return b;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<DailyWorkoutLogProvider>();
    final week = _currentWeek();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final todayStatus = provider.statusFor(todayKey);

    if (provider.loading) {
      return const LiaqhPageLoader();
    }

    final stats = context.watch<CoachingProvider>().stats;

    return Stack(
      children: [
        RefreshIndicator(
      onRefresh: () async {
        await context.read<DailyWorkoutLogProvider>().load(widget.traineeId);
        await context.read<CoachingProvider>().loadStats(widget.traineeId);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).padding.bottom + 90),
        children: [
          // ── Streak + weekly goal + badges ─────────────────────────────
          _StatsHeader(
            stats: stats,
            colors: colors,
            l10n: l10n,
            onEditGoal: widget.readOnly ? _pickWeeklyGoal : null,
            badgeLabel: (b) => _badgeLabel(l10n, b),
          ),
          const SizedBox(height: 24),
          // ── This week strip ───────────────────────────────────────────
          Text(l10n.thisWeekLabel,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15, color: colors.fg)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: week.map((d) {
              final isToday = d == todayKey;
              final isFuture = d.isAfter(todayKey);
              final st = provider.statusFor(d);
              Color bg;
              Widget icon;
              if (st == true) {
                bg = AppColors.successColor;
                icon = const Icon(Icons.check, color: Colors.white, size: 16);
              } else if (st == false) {
                bg = const Color(0xFFEF4444);
                icon = const Icon(Icons.close, color: Colors.white, size: 16);
              } else {
                bg = colors.listTile;
                icon = Icon(Icons.remove,
                    color: colors.subFg.withValues(alpha: 0.5), size: 16);
              }
              return Expanded(
                child: GestureDetector(
                  // Only the trainee (own profile = readOnly) may log; not future days.
                  onTap: (!widget.readOnly || isFuture)
                      ? null
                      : () => _showDayPicker(d),
                  child: Column(
                    children: [
                      Text(dayShortName(context, d.weekday % 7),
                          style: TextStyle(
                              fontSize: 10,
                              color: isToday
                                  ? AppColors.primaryColor1
                                  : colors.subFg,
                              fontWeight: isToday
                                  ? FontWeight.w800
                                  : FontWeight.w500)),
                      const SizedBox(height: 6),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: bg,
                          shape: BoxShape.circle,
                          border: isToday
                              ? Border.all(
                                  color: AppColors.primaryColor1, width: 2)
                              : null,
                        ),
                        child: Center(child: icon),
                      ),
                      const SizedBox(height: 4),
                      Text('${d.day}',
                          style: TextStyle(fontSize: 10, color: colors.subFg)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Today's confirm (trainee only) ────────────────────────────
          if (widget.readOnly)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor1, AppColors.primaryColor2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.didYouWorkoutToday,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _confirmBtn(
                          label: l10n.workedOut,
                          icon: Icons.check_circle,
                          selected: todayStatus == true,
                          onTap: provider.saving
                              ? null
                              : () => _log(todayKey, true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _confirmBtn(
                          label: l10n.restDay,
                          icon: Icons.bedtime,
                          selected: todayStatus == false,
                          onTap: provider.saving
                              ? null
                              : () => _log(todayKey, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // ── Nutrition confirm (trainee only) ──────────────────────────
          if (widget.readOnly) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant_rounded,
                          color: AppColors.successColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(l10n.nutritionTodayQuestion,
                            style: TextStyle(
                                color: colors.fg,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _confirmBtn(
                          label: l10n.followedNutrition,
                          icon: Icons.check_circle,
                          selected: provider.nutritionFor(todayKey) == true,
                          onTap: provider.saving
                              ? null
                              : () => context
                                  .read<DailyWorkoutLogProvider>()
                                  .log(todayKey, todayStatus ?? false,
                                      followedNutrition: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _confirmBtn(
                          label: l10n.missedNutrition,
                          icon: Icons.cancel,
                          selected: provider.nutritionFor(todayKey) == false,
                          onTap: provider.saving
                              ? null
                              : () => context
                                  .read<DailyWorkoutLogProvider>()
                                  .log(todayKey, todayStatus ?? false,
                                      followedNutrition: false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // ── Workout reminder (trainee only) ───────────────────────────
          if (widget.readOnly) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor1.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.alarm,
                            color: AppColors.primaryColor1, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.workoutReminder,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: colors.fg)),
                            Text(l10n.workoutReminderHint,
                                style: TextStyle(
                                    fontSize: 11, color: colors.subFg)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _reminderEnabled,
                        activeThumbColor: AppColors.primaryColor1,
                        onChanged: _toggleReminder,
                      ),
                    ],
                  ),
                  if (_reminderEnabled) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickReminderTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.listTile,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                color: AppColors.primaryColor1, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                  l10n.reminderSetFor(
                                      _reminderTime.format(context)),
                                  style: TextStyle(
                                      fontSize: 13, color: colors.fg)),
                            ),
                            Text(l10n.setTime,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor1)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── History ───────────────────────────────────────────────────
          Text(l10n.logHistory,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15, color: colors.fg)),
          const SizedBox(height: 10),
          if (provider.history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                  child: Text(l10n.noLogsYet,
                      style: TextStyle(color: colors.subFg))),
            )
          else
            ...provider.history.map((log) {
              final done = log.didWorkout;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.listTile,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(done ? Icons.check_circle : Icons.bedtime,
                        color: done
                            ? AppColors.successColor
                            : colors.subFg,
                        size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_fmtLogDate(log.date),
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.fg)),
                    ),
                    Text(done ? l10n.loggedWorkedOut : l10n.loggedRest,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: done
                                ? AppColors.successColor
                                : colors.subFg)),
                  ],
                ),
              );
            }),
        ],
      ),
        ),
        // Celebration confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 25,
            gravity: 0.25,
            colors: const [
              AppColors.primaryColor1,
              Color(0xFF10B981),
              Color(0xFFFFC107),
              Color(0xFF6366F1),
            ],
          ),
        ),
      ],
    );
  }

  /// Lets the trainee set a past day in the current week.
  Future<void> _showDayPicker(DateTime day) async {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final choice = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(_fmtLogDate(day),
                style: TextStyle(
                    color: colors.fg, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.check_circle,
                  color: AppColors.successColor),
              title: Text(l10n.workedOut, style: TextStyle(color: colors.fg)),
              onTap: () => Navigator.pop(ctx, true),
            ),
            ListTile(
              leading: Icon(Icons.bedtime, color: colors.subFg),
              title: Text(l10n.restDay, style: TextStyle(color: colors.fg)),
              onTap: () => Navigator.pop(ctx, false),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice != null) _log(day, choice);
  }

  Widget _confirmBtn({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? AppColors.primaryColor1 : Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: selected ? AppColors.primaryColor1 : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  String _fmtLogDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Streak / weekly goal / badges header ───────────────────────────────────────
class _StatsHeader extends StatelessWidget {
  final WorkoutStats stats;
  final AppThemeColors colors;
  final AppLocalizations l10n;
  final VoidCallback? onEditGoal;
  final String Function(String) badgeLabel;
  const _StatsHeader({
    required this.stats,
    required this.colors,
    required this.l10n,
    required this.onEditGoal,
    required this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final goalPct = stats.weeklyGoal == 0
        ? 0.0
        : (stats.thisWeekCount / stats.weeklyGoal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD97757), Color(0xFFB85C38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Streak
              Expanded(
                child: Column(
                  children: [
                    Text('🔥 ${stats.currentStreak}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900)),
                    Text(l10n.dayStreak,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              // Weekly goal ring
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: CircularProgressIndicator(
                        value: goalPct,
                        strokeWidth: 7,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${stats.thisWeekCount}/${stats.weeklyGoal}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                        Text(l10n.weeklyGoalLabel,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ),
              // Total
              Expanded(
                child: Column(
                  children: [
                    Text('${stats.totalWorkouts}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900)),
                    Text(l10n.totalWorkouts,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          if (stats.badges.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: stats.badges.map((b) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('🏅 ${badgeLabel(b)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                );
              }).toList(),
            ),
          ],
          if (onEditGoal != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onEditGoal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.tune_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(l10n.setWeeklyGoal,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Nutrition Tab ─────────────────────────────────────────────────────────────
class _NutritionTab extends StatelessWidget {
  final String traineeId;
  final String traineeName;
  final bool readOnly;
  final double heightCm;
  final double currentWeightKg;
  final String goal;
  final String? traineeUserId;
  const _NutritionTab(
      {required this.traineeId,
      required this.traineeName,
      this.readOnly = false,
      this.heightCm = 0,
      this.currentWeightKg = 0,
      this.goal = 'Maintain',
      this.traineeUserId});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<MealProvider>();

    if (provider.loading) {
      return const LiaqhPageLoader();
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
            // Action row — icon-only buttons
            if (!readOnly || plan != null)
              Row(
                children: [
                  if (!readOnly)
                    _NutritionActionButton(
                      icon: Icons.add,
                      tooltip: plan == null
                          ? AppLocalizations.of(context).createPlan
                          : AppLocalizations.of(context).newPlan,
                      filled: true,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateMealPlanScreen(
                            traineeId: traineeId,
                            traineeName: traineeName,
                            heightCm: heightCm,
                            currentWeightKg: currentWeightKg,
                            goal: goal,
                          ),
                        ),
                      ).then((_) => context
                          .read<MealProvider>()
                          .loadActivePlan(traineeId)),
                    ),
                  if (plan != null) ...[
                    if (!readOnly) ...[
                      const SizedBox(width: 10),
                      _NutritionActionButton(
                        icon: Icons.edit_outlined,
                        tooltip: AppLocalizations.of(context).edit,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BuildMealPlanScreen(
                                planId: plan.id, traineeName: traineeName),
                          ),
                        ).then((_) => context
                            .read<MealProvider>()
                            .loadActivePlan(traineeId)),
                      ),
                    ],
                    const SizedBox(width: 10),
                    _NutritionActionButton(
                      icon: Icons.shopping_cart_outlined,
                      tooltip: AppLocalizations.of(context).shop,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShoppingListScreen(planId: plan.id),
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
                            ? AppLocalizations.of(context).coachNoMealPlanYet
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
              if (plan.isFile) ...[
                Text(AppLocalizations.of(context).planFile,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: colors.fg)),
                const SizedBox(height: 10),
                AttachmentsView(urls: [plan.attachmentUrl!]),
                const SizedBox(height: 16),
              ] else ...[
                // Day summaries
                Text(AppLocalizations.of(context).thisWeek,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: colors.fg)),
                const SizedBox(height: 10),
                ...plan.days.map((day) => _NutritionDayRow(day: day)),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MealPlanViewScreen(
                              plan: plan,
                              traineeId: traineeId,
                              canReject: readOnly),
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

class _NutritionActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool filled;
  const _NutritionActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled
            ? AppColors.primaryColor1
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: filled
                  ? null
                  : Border.all(color: AppColors.primaryColor1, width: 1.4),
            ),
            child: Icon(
              icon,
              size: 20,
              color: filled ? Colors.white : AppColors.primaryColor1,
            ),
          ),
        ),
      ),
    );
  }
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
                dayBadge(context, day.dayOfWeek),
                style: const TextStyle(
                    color: Color(0xFF43A047),
                    fontWeight: FontWeight.w800,
                    fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? day.dayNameAr
                    : day.dayName,
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
