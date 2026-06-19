import 'package:fitnessapp/data/models/membership_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/membership_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubscribeTraineeScreen extends StatefulWidget {
  final String traineeId;
  final String gymId;

  const SubscribeTraineeScreen({
    Key? key,
    required this.traineeId,
    required this.gymId,
  }) : super(key: key);

  @override
  State<SubscribeTraineeScreen> createState() => _SubscribeTraineeScreenState();
}

class _SubscribeTraineeScreenState extends State<SubscribeTraineeScreen> {
  MembershipPlanModel? _selectedPlan;
  DateTime _startDate = DateTime.now();
  bool _autoRenew = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show only the plans this user may assign (coach → own; gym admin → gym).
      context.read<MembershipProvider>().loadAssignablePlans();
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedPlan == null) {
      setState(() => _error = l10n.selectPlanFirst);
      return;
    }
    setState(() => _error = null);

    final ok = await context.read<MembershipProvider>().subscribe(
          traineeId: widget.traineeId,
          planId: _selectedPlan!.id,
          startDate: _startDate,
          autoRenew: _autoRenew,
        );
    if (ok && mounted) Navigator.pop(context);
  }

  Future<void> _showAddPlanSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPlanSheet(gymId: widget.gymId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<MembershipProvider>();
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.subscribeToPlan,
            style: TextStyle(
                fontWeight: FontWeight.w700, color: colors.fg, fontSize: 17)),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
      ),
      body: provider.loading
          ? const LiaqhPageLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Plan section header ───────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(l10n.selectPlan,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: colors.fg)),
                      ),
                      GestureDetector(
                        onTap: _showAddPlanSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient:
                                LinearGradient(colors: AppColors.primaryG),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('Add Plan',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Plan list ─────────────────────────────────────────
                  if (provider.plans.isEmpty)
                    Text(l10n.noPlansAvailable,
                        style: TextStyle(color: colors.subFg))
                  else
                    ...provider.plans.map((plan) => _PlanTile(
                          plan: plan,
                          selected: _selectedPlan?.id == plan.id,
                          onTap: () => setState(() => _selectedPlan = plan),
                          planDurationLabel: l10n.planDuration(
                              plan.durationDays, plan.billingCycle),
                        )),

                  const SizedBox(height: 24),

                  // ── Start date ────────────────────────────────────────
                  Text(l10n.startDate,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colors.fg)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 30)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.listTile,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.primaryColor1, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            _startDate.toString().substring(0, 10),
                            style: TextStyle(
                                fontWeight: FontWeight.w500, color: colors.fg),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Auto-renew ────────────────────────────────────────
                  Row(
                    children: [
                      Switch(
                        value: _autoRenew,
                        onChanged: (v) => setState(() => _autoRenew = v),
                        activeThumbColor: AppColors.primaryColor1,
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.autoRenew,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: colors.fg)),
                    ],
                  ),

                  if (_error != null || provider.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error ?? provider.error!,
                      style: const TextStyle(
                          color: AppColors.errorColor, fontSize: 13),
                    ),
                  ],

                  SizedBox(height: media.width * 0.06),
                  ElevatedButton(
                    onPressed: provider.loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor1,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(l10n.confirmSubscription,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Add Plan Bottom Sheet ─────────────────────────────────────────────────────

class _AddPlanSheet extends StatefulWidget {
  final String gymId;
  const _AddPlanSheet({required this.gymId});

  @override
  State<_AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends State<_AddPlanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _daysCtrl = TextEditingController(text: '30');
  String _billingCycle = 'Monthly';
  bool _isFree = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<MembershipProvider>();
    final ok = await provider.createPlan(
      gymId: widget.gymId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      price: _isFree ? 0 : double.parse(_priceCtrl.text.trim()),
      durationDays: int.parse(_daysCtrl.text.trim()),
      billingCycle: _billingCycle,
      isFree: _isFree,
      reloadCoachPlans: true,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final loading = context.watch<MembershipProvider>().loading;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text('New Membership Plan',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.fg)),
            const SizedBox(height: 20),

            _Field(
              controller: _nameCtrl,
              label: 'Plan Name',
              hint: 'e.g. Premium, Standard',
              colors: colors,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _descCtrl,
              label: 'Description (optional)',
              hint: 'e.g. Full gym access',
              colors: colors,
            ),
            const SizedBox(height: 12),

            // Free plan toggle — grants access with no payment required.
            Container(
              decoration: BoxDecoration(
                color: colors.listTile,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                value: _isFree,
                onChanged: (v) => setState(() => _isFree = v),
                activeThumbColor: AppColors.primaryColor1,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                title: Text('Free plan',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.fg)),
                subtitle: Text('Trainee gets access without paying',
                    style: TextStyle(fontSize: 12, color: colors.subFg)),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                if (!_isFree) ...[
                  Expanded(
                    child: _Field(
                      controller: _priceCtrl,
                      label: 'Price (EGP)',
                      hint: '500',
                      colors: colors,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (_isFree) return null;
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: _Field(
                    controller: _daysCtrl,
                    label: 'Duration (days)',
                    hint: '30',
                    colors: colors,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Billing cycle chips
            Text('Billing Cycle',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.subFg)),
            const SizedBox(height: 8),
            Row(
              children: ['Daily', 'Weekly', 'Monthly'].map((cycle) {
                final selected = _billingCycle == cycle;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _billingCycle = cycle),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? LinearGradient(colors: AppColors.primaryG)
                            : null,
                        color: selected ? null : colors.listTile,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(cycle,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  selected ? Colors.white : colors.subFg)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor1,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create Plan',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final AppThemeColors colors;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.colors,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(color: colors.fg, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: colors.subFg, fontSize: 13),
          hintStyle: TextStyle(color: colors.mutedFg, fontSize: 13),
          filled: true,
          fillColor: colors.listTile,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}

// ── Plan Tile ─────────────────────────────────────────────────────────────────

class _PlanTile extends StatelessWidget {
  final MembershipPlanModel plan;
  final bool selected;
  final VoidCallback onTap;
  final String planDurationLabel;

  const _PlanTile({
    required this.plan,
    required this.selected,
    required this.onTap,
    required this.planDurationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isStandard = plan.name.toLowerCase() == 'standard';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor1.withValues(alpha: 0.08)
              : colors.listTile,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primaryColor1 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.primaryColor1 : colors.subFg,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plan.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: colors.fg)),
                      if (isStandard) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor1.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Default',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor1)),
                        ),
                      ],
                    ],
                  ),
                  if (plan.description != null)
                    Text(plan.description!,
                        style: TextStyle(color: colors.subFg, fontSize: 12)),
                  Text(planDurationLabel,
                      style: TextStyle(color: colors.subFg, fontSize: 12)),
                ],
              ),
            ),
            Text(
              plan.isFree ? 'Free' : 'EGP ${plan.price.toStringAsFixed(0)}',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: plan.isFree ? Colors.blue : AppColors.primaryColor1,
                  fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
