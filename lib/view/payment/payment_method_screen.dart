import 'package:fitnessapp/data/models/payment_method_models.dart';
import 'package:fitnessapp/providers/payment_methods_provider.dart';
import 'package:fitnessapp/providers/payment_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/payment/checkout_launcher_screen.dart';
import 'package:fitnessapp/view/payment/manual_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Lets the trainee choose how to pay for the system subscription:
/// Paddle (online) or a manual transfer (InstaPay / Wallet).
class PaymentMethodScreen extends StatefulWidget {
  static const routeName = '/PaymentMethodScreen';
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<PaymentMethodsProvider>().loadMethods());
  }

  IconData _iconFor(String code) {
    switch (code) {
      case 'Paddle':
        return Icons.credit_card_rounded;
      case 'InstaPay':
        return Icons.account_balance_rounded;
      case 'Wallet':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Future<void> _choose(PaymentMethodModel m) async {
    if (m.isManual) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => ManualPaymentScreen(method: m)),
      );
      if (ok == true && mounted) Navigator.pop(context, true);
      return;
    }

    // Paddle — online checkout.
    final pp = context.read<PaymentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await pp.startCheckout();
    if (!mounted) return;
    if (result == null) {
      messenger.showSnackBar(SnackBar(
          content: Text(pp.error ?? 'Could not start checkout.'),
          backgroundColor: AppColors.errorColor));
      return;
    }
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutLauncherScreen(
          checkoutUrl: result.checkoutUrl,
          sessionId: result.sessionId,
        ),
      ),
    );
    if (success == true && mounted) {
      await context.read<PaymentProvider>().loadAccess();
      if (mounted) Navigator.pop(context, true);
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
        title: Text('Choose payment method',
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: provider.loading && provider.methods.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.methods.isEmpty
              ? Center(
                  child: Text('No payment methods available.',
                      style: TextStyle(color: colors.subFg)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final m in provider.methods)
                      _MethodTile(
                        method: m,
                        icon: _iconFor(m.code),
                        colors: colors,
                        onTap: () => _choose(m),
                      ),
                  ],
                ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentMethodModel method;
  final IconData icon;
  final AppThemeColors colors;
  final VoidCallback onTap;
  const _MethodTile({
    required this.method,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryColor1.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor1),
        ),
        title: Text(method.name,
            style: TextStyle(
                color: colors.fg, fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(
          method.isManual
              ? 'Manual transfer · reviewed within 24h'
              : 'Instant online payment',
          style: TextStyle(color: colors.subFg, fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: colors.mutedFg),
        onTap: onTap,
      ),
    );
  }
}
