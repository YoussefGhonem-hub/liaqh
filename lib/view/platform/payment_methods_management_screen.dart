import 'package:fitnessapp/data/models/payment_method_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/payment_methods_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Platform Owner: activate/deactivate and edit payment methods.
class PaymentMethodsManagementScreen extends StatefulWidget {
  static const routeName = '/PaymentMethodsManagementScreen';
  const PaymentMethodsManagementScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsManagementScreen> createState() =>
      _PaymentMethodsManagementScreenState();
}

class _PaymentMethodsManagementScreenState
    extends State<PaymentMethodsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<PaymentMethodsProvider>();
      p.loadMethods(all: true);
      p.loadPlatformSettings();
    });
  }

  Future<void> _edit(PaymentMethodModel m) async {
    final colors = context.colors;
    final receiverCtrl = TextEditingController(text: m.receiverNumber ?? '');
    final instrCtrl = TextEditingController(text: m.instructions ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        title: Text('Edit ${m.name}', style: TextStyle(color: colors.fg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: receiverCtrl,
              style: TextStyle(color: colors.fg),
              decoration: const InputDecoration(labelText: 'Receiver number'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: instrCtrl,
              style: TextStyle(color: colors.fg),
              decoration: const InputDecoration(labelText: 'Instructions / hint'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );

    if (saved == true && mounted) {
      await context.read<PaymentMethodsProvider>().updateMethod(
            m.id,
            receiverNumber: receiverCtrl.text.trim(),
            instructions: instrCtrl.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<PaymentMethodsProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text('Payment Methods',
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: provider.loading && provider.methods.isEmpty
          ? const LiaqhPageLoader()
          : RefreshIndicator(
              onRefresh: () => provider.loadMethods(all: true),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Global control: require a system (Type 1) subscription.
                  _RequireSystemCard(
                    value: provider.requireSystemSubscription,
                    colors: colors,
                    onChanged: (v) async {
                      final ok = await context
                          .read<PaymentMethodsProvider>()
                          .setRequireSystemSubscription(v);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not update setting')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  for (final m in provider.methods)
                    _MethodCard(
                      method: m,
                      colors: colors,
                      // Methods are only meaningful while a system subscription
                      // is required — otherwise the toggles are disabled.
                      enabled: provider.requireSystemSubscription,
                      onToggle: (v) => provider.updateMethod(m.id, isActive: v),
                      onEdit: m.isManual ? () => _edit(m) : null,
                    ),
                ],
              ),
            ),
    );
  }
}

/// Global toggle: when OFF, trainees do NOT need a system (Type 1) subscription —
/// only their coach payment gates access. Coaches keep working normally.
class _RequireSystemCard extends StatelessWidget {
  final bool value;
  final AppThemeColors colors;
  final ValueChanged<bool> onChanged;
  const _RequireSystemCard({
    required this.value,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: value
                ? AppColors.primaryColor1.withValues(alpha: 0.4)
                : colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.primaryColor1),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Require system subscription',
                    style: TextStyle(
                        color: colors.fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
              Switch(
                value: value,
                activeThumbColor: AppColors.primaryColor1,
                onChanged: onChanged,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value
                ? 'Trainees must pay the system subscription AND their coach.'
                : 'System payment is OFF — trainees only need to pay their coach.',
            style: TextStyle(color: colors.subFg, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final PaymentMethodModel method;
  final AppThemeColors colors;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onEdit;
  const _MethodCard({
    required this.method,
    required this.colors,
    this.enabled = true,
    required this.onToggle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.name,
                        style: TextStyle(
                            color: colors.fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text(
                      method.isManual ? 'Manual · needs approval' : 'Online (Paddle)',
                      style: TextStyle(color: colors.subFg, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: method.isActive,
                activeThumbColor: AppColors.primaryColor1,
                onChanged: enabled ? onToggle : null,
              ),
            ],
          ),
          if (method.receiverNumber != null &&
              method.receiverNumber!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Receiver: ${method.receiverNumber}',
                style: TextStyle(color: colors.subFg, fontSize: 13)),
          ],
          if (onEdit != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: enabled ? onEdit : null,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
