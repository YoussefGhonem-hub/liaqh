import 'package:fitnessapp/data/models/payment_models.dart';
import 'package:fitnessapp/providers/payment_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/payment/checkout_launcher_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SubscriptionScreen extends StatefulWidget {
  static const routeName = '/SubscriptionScreen';
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<PaymentProvider>().loadSubscriptions());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pp = context.watch<PaymentProvider>();
    final activeSub = pp.subscriptions.where((s) => s.isActive).firstOrNull;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        title: Text('My Subscription',
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: colors.fg),
        elevation: 0,
      ),
      body: pp.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<PaymentProvider>().loadSubscriptions(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlanCard(activeSub: activeSub, colors: colors),
                    if (activeSub != null) ...[
                      const SizedBox(height: 24),
                      _ActiveSubDetails(sub: activeSub, colors: colors),
                    ],
                    if (pp.subscriptions.isNotEmpty &&
                        pp.subscriptions
                            .any((s) => s.recentTransactions.isNotEmpty)) ...[
                      const SizedBox(height: 24),
                      _PaymentHistory(subs: pp.subscriptions, colors: colors),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final PaymentSubscription? activeSub;
  final dynamic colors;
  const _PlanCard({required this.activeSub, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isActive = activeSub?.isActive ?? false;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryG,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                isActive ? 'ACTIVE' : 'STANDARD PLAN',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8),
              ),
            ),
            const Spacer(),
            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          ]),
          const SizedBox(height: 16),
          const Text('Standard',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('30',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    height: 1)),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('EGP / month',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
          ]),
          const SizedBox(height: 16),
          const _Feature(text: 'Unlimited workout programs'),
          const _Feature(text: 'Meal plan & nutrition tracking'),
          const _Feature(text: 'InBody & progress tracking'),
          const _Feature(text: 'Direct coach messaging'),
          const SizedBox(height: 20),
          if (!isActive)
            _SubscribeButton(colors: colors)
          else
            _ActiveBadge(sub: activeSub!),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final String text;
  const _Feature({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
        ]),
      );
}

class _SubscribeButton extends StatelessWidget {
  final dynamic colors;
  const _SubscribeButton({required this.colors});

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PaymentProvider>();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryColor1,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: pp.checkoutLoading ? null : () => _startCheckout(context),
        child: pp.checkoutLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Subscribe Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Future<void> _startCheckout(BuildContext context) async {
    final pp = context.read<PaymentProvider>();
    final result = await pp.startCheckout();
    if (!context.mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(pp.error ?? 'Failed to start checkout.'),
          backgroundColor: AppColors.errorColor));
      return;
    }

    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutLauncherScreen(
          checkoutUrl: result.checkoutUrl,
          sessionId: result.sessionId,
          onSuccess: () => context.read<PaymentProvider>().loadSubscriptions(),
        ),
      ),
    );

    if (success == true && context.mounted) {
      context.read<PaymentProvider>().loadSubscriptions();
    }
  }
}

class _ActiveBadge extends StatelessWidget {
  final PaymentSubscription sub;
  const _ActiveBadge({required this.sub});

  @override
  Widget build(BuildContext context) {
    final end = sub.currentPeriodEnd;
    final fmt = DateFormat('MMM d, yyyy');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          end != null
              ? 'Active until ${fmt.format(end)}'
              : 'Subscription active',
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}

// ── Active subscription details ───────────────────────────────────────────────

class _ActiveSubDetails extends StatelessWidget {
  final PaymentSubscription sub;
  final dynamic colors;
  const _ActiveSubDetails({required this.sub, required this.colors});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subscription Details',
              style: TextStyle(
                  color: colors.fg, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (sub.nextBillDate != null)
            _InfoRow(
                colors: colors,
                label: 'Next billing date',
                value: fmt.format(sub.nextBillDate!)),
          if (sub.currentPeriodEnd != null)
            _InfoRow(
                colors: colors,
                label: 'Current period ends',
                value: fmt.format(sub.currentPeriodEnd!)),
          _InfoRow(
              colors: colors,
              label: 'Amount',
              value: '${sub.currency} ${sub.unitPrice.toStringAsFixed(2)}'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                foregroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _confirmCancel(context),
              child: const Text('Cancel Subscription'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
            'Your subscription will be cancelled at the end of the current billing period.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep it')),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<PaymentProvider>()
                  .cancelSubscription(sub.paddleSubscriptionId);
            },
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }
}

// ── Payment history ───────────────────────────────────────────────────────────

class _PaymentHistory extends StatelessWidget {
  final List<PaymentSubscription> subs;
  final dynamic colors;
  const _PaymentHistory({required this.subs, required this.colors});

  @override
  Widget build(BuildContext context) {
    final transactions = subs.expand((s) => s.recentTransactions).toList()
      ..sort((a, b) =>
          (b.billedAt ?? DateTime(0)).compareTo(a.billedAt ?? DateTime(0)));

    final fmt = DateFormat('MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment History',
            style: TextStyle(
                color: colors.fg, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...transactions.take(5).map((t) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor1.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.receipt_rounded,
                      color: AppColors.primaryColor1, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Standard Plan',
                          style: TextStyle(
                              color: colors.fg,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      if (t.billedAt != null)
                        Text(fmt.format(t.billedAt!),
                            style:
                                TextStyle(color: colors.mutedFg, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${t.currency} ${t.total.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: colors.fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    if (t.cardLast4 != null)
                      Text('···${t.cardLast4}',
                          style:
                              TextStyle(color: colors.mutedFg, fontSize: 11)),
                  ],
                ),
              ]),
            )),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final dynamic colors;
  final String label;
  final String value;
  const _InfoRow(
      {required this.colors, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text(label, style: TextStyle(color: colors.mutedFg, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: colors.fg, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      );
}
