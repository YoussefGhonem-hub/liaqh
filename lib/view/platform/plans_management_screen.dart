import 'package:fitnessapp/data/models/platform_models.dart';
import 'package:fitnessapp/providers/platform_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'platform_widgets.dart';

class PlansManagementScreen extends StatefulWidget {
  static const routeName = '/PlansManagementScreen';
  final String gymId;
  final String gymName;
  const PlansManagementScreen({
    super.key,
    required this.gymId,
    required this.gymName,
  });

  @override
  State<PlansManagementScreen> createState() => _PlansManagementScreenState();
}

class _PlansManagementScreenState extends State<PlansManagementScreen> {
  static const _cycles = ['Monthly', 'Quarterly', 'Annual'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() => context.read<PlatformProvider>().loadPlans(widget.gymId);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = context.watch<PlatformProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primaryColor1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Plan',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PlatformGradientHeader(
                title: 'Membership Plans',
                subtitle: widget.gymName,
                icon: Icons.card_membership_rounded,
                showBack: true,
              ),
            ),
            if (p.plansLoading && p.plans.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (p.plansError != null && p.plans.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child:
                    PlatformErrorState(message: p.plansError!, onRetry: _load),
              )
            else if (p.plans.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformEmptyState(
                    icon: Icons.card_membership_rounded,
                    message: 'No plans yet'),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _planTile(p.plans[i]),
                    ),
                    childCount: p.plans.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _planTile(PlatformPlan pl) {
    final colors = context.colors;
    final dim = !pl.isActive;
    return Opacity(
      opacity: dim ? 0.6 : 1,
      child: PlatformCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor1.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.card_membership_rounded,
                      color: AppColors.primaryColor1, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(pl.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: colors.fg,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                          ),
                          if (!pl.isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.errorColor
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text('Inactive',
                                  style: TextStyle(
                                      color: AppColors.errorColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${pl.billingCycle} · ${pl.durationDays} days',
                          style: TextStyle(
                              color: colors.subFg, fontSize: 12)),
                    ],
                  ),
                ),
                Text(platformMoney(pl.price, 'EGP'),
                    style: TextStyle(
                        color: colors.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            if (pl.description != null && pl.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(pl.description!,
                  style: TextStyle(color: colors.subFg, fontSize: 12)),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openForm(plan: pl),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(pl),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.errorColor),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(PlatformPlan pl) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Delete "${pl.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context
          .read<PlatformProvider>()
          .deletePlan(gymId: widget.gymId, id: pl.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete plan: $e')),
        );
      }
    }
  }

  void _openForm({PlatformPlan? plan}) {
    final isEdit = plan != null;
    final nameCtrl = TextEditingController(text: plan?.name ?? '');
    final descCtrl = TextEditingController(text: plan?.description ?? '');
    final priceCtrl =
        TextEditingController(text: plan != null ? '${plan.price}' : '');
    final daysCtrl = TextEditingController(
        text: plan != null ? '${plan.durationDays}' : '30');
    String cycle = (plan != null && _cycles.contains(plan.billingCycle))
        ? plan.billingCycle
        : 'Monthly';
    bool active = plan?.isActive ?? true;
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colors = ctx.colors;
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.bg,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colors.divider,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(isEdit ? 'Edit Plan' : 'Add Plan',
                            style: TextStyle(
                                color: colors.fg,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        _field(nameCtrl, 'Name',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null),
                        const SizedBox(height: 12),
                        _field(descCtrl, 'Description (optional)',
                            maxLines: 2),
                        const SizedBox(height: 12),
                        _field(priceCtrl, 'Price (EGP)',
                            keyboardType: const TextInputType
                                .numberWithOptions(decimal: true),
                            validator: (v) {
                          final d = double.tryParse(v ?? '');
                          if (d == null || d < 0) return 'Enter a valid price';
                          return null;
                        }),
                        const SizedBox(height: 12),
                        _field(daysCtrl, 'Duration (days)',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Enter valid days';
                          return null;
                        }),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: cycle,
                          decoration: InputDecoration(
                            labelText: 'Billing cycle',
                            filled: true,
                            fillColor: colors.inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: [
                            for (final c in _cycles)
                              DropdownMenuItem(value: c, child: Text(c)),
                          ],
                          onChanged: (v) =>
                              setSheet(() => cycle = v ?? cycle),
                        ),
                        if (isEdit) ...[
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Active',
                                style: TextStyle(color: colors.fg)),
                            value: active,
                            activeThumbColor: AppColors.primaryColor1,
                            onChanged: (v) => setSheet(() => active = v),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: saving
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    setSheet(() => saving = true);
                                    final provider =
                                        context.read<PlatformProvider>();
                                    final navigator = Navigator.of(ctx);
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    try {
                                      final desc = descCtrl.text.trim();
                                      if (isEdit) {
                                        await provider.updatePlan(
                                          gymId: widget.gymId,
                                          id: plan.id,
                                          name: nameCtrl.text.trim(),
                                          description:
                                              desc.isEmpty ? null : desc,
                                          price: double.parse(
                                              priceCtrl.text.trim()),
                                          durationDays: int.parse(
                                              daysCtrl.text.trim()),
                                          billingCycle: cycle,
                                          isActive: active,
                                        );
                                      } else {
                                        await provider.createPlan(
                                          gymId: widget.gymId,
                                          name: nameCtrl.text.trim(),
                                          description:
                                              desc.isEmpty ? null : desc,
                                          price: double.parse(
                                              priceCtrl.text.trim()),
                                          durationDays: int.parse(
                                              daysCtrl.text.trim()),
                                          billingCycle: cycle,
                                        );
                                      }
                                      navigator.pop();
                                    } catch (e) {
                                      setSheet(() => saving = false);
                                      messenger.showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Failed to save: $e')),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor1,
                              minimumSize: const Size(0, 50),
                            ),
                            child: saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : Text(isEdit ? 'Save Changes' : 'Create Plan',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final colors = context.colors;
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: colors.fg),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
