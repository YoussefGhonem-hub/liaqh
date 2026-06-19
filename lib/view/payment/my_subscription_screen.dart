import 'package:fitnessapp/data/models/payment_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/payment_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/utils/status_l10n.dart';
import 'package:fitnessapp/view/payment/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Shows the logged-in trainee's current plan, renewal details and payments.
class MySubscriptionScreen extends StatefulWidget {
  static const routeName = '/MySubscriptionScreen';
  const MySubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  final _fmt = DateFormat('MMM d, yyyy');

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<PaymentProvider>().loadMySubscription());
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Active':
        return AppColors.successColor;
      case 'Frozen':
      case 'PastDue':
        return AppColors.warningColor;
      case 'Expired':
      case 'Cancelled':
        return AppColors.errorColor;
      default:
        return Colors.grey;
    }
  }

  Future<void> _confirmCancel(MySubscription sub) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.cancelSubscriptionQ),
        content: const Text(
            'Your subscription stays active until the end of the current billing period, then it will not renew.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.keepIt)),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.cancelSubscription),
          ),
        ],
      ),
    );
    if (ok == true && sub.paddleSubscriptionId != null && mounted) {
      final pp = context.read<PaymentProvider>();
      await pp.cancelSubscription(sub.paddleSubscriptionId!);
      await pp.loadMySubscription();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pp = context.watch<PaymentProvider>();
    final sub = pp.mySubscription;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
        title: Text(l10n.drawerMySubscription,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 18, color: colors.fg)),
      ),
      body: pp.mySubLoading && sub == null
          ? const LiaqhPageLoader()
          : sub == null
              ? Center(
                  child: Text(l10n.couldNotLoadSubscription,
                      style: TextStyle(color: colors.subFg)))
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<PaymentProvider>().loadMySubscription(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    children: [
                      _hero(sub, colors),
                      const SizedBox(height: 20),
                      if (sub.hasActiveMembership)
                        _detailsCard(sub, colors)
                      else
                        _subscribeCta(colors),
                      if (sub.recentPayments.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(l10n.paymentHistory,
                            style: TextStyle(
                                color: colors.fg,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        ...sub.recentPayments
                            .map((t) => _paymentRow(t, colors)),
                      ],
                    ],
                  ),
                ),
    );
  }

  // ── Hero card ──────────────────────────────────────────────────────────────
  Widget _hero(MySubscription sub, dynamic colors) {
    final active = sub.hasActiveMembership;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: active
              ? AppColors.primaryG
              : [colors.card as Color, colors.card as Color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: active
            ? [
                BoxShadow(
                    color: AppColors.primaryColor1.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6))
              ]
            : null,
        border: active ? null : Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.2)
                      : _statusColor(sub.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subStatusLabel(l10n, sub.status),
                  style: TextStyle(
                    color: active ? Colors.white : _statusColor(sub.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.workspace_premium_rounded,
                  color: active ? Colors.amber : colors.mutedFg, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            sub.planName ?? 'No active plan',
            style: TextStyle(
              color: active ? Colors.white : colors.fg,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (sub.price != null) ...[
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(sub.price!.toStringAsFixed(0),
                  style: TextStyle(
                      color: active ? Colors.white : AppColors.primaryColor1,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${sub.currency} / ${(sub.billingCycle ?? 'month').toLowerCase()}',
                  style: TextStyle(
                      color: active
                          ? Colors.white.withValues(alpha: 0.85)
                          : colors.subFg,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ],
          if (active && sub.daysRemaining != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(l10n.daysRemainingCount(sub.daysRemaining!),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  // ── Details card ─────────────────────────────────────────────────────────
  Widget _detailsCard(MySubscription sub, dynamic colors) {
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
          Text(l10n.subscriptionDetails,
              style: TextStyle(
                  color: colors.fg, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (sub.startDate != null)
            _row(colors, Icons.event_available_outlined, l10n.started,
                _fmt.format(sub.startDate!)),
          if (sub.endDate != null)
            _row(
                colors,
                Icons.event_busy_outlined,
                sub.autoRenew ? l10n.renewsOn : l10n.expiresOn,
                _fmt.format(sub.endDate!)),
          _row(
              colors,
              sub.autoRenew
                  ? Icons.autorenew_rounded
                  : Icons.do_not_disturb_on_outlined,
              l10n.autoRenew,
              sub.autoRenew ? l10n.settingOn : l10n.settingOff),
          if (sub.isRecurring && sub.nextBillDate != null)
            _row(colors, Icons.receipt_long_outlined, l10n.nextBilling,
                _fmt.format(sub.nextBillDate!)),
          _row(colors, Icons.payments_outlined, l10n.amount,
              '${sub.currency} ${(sub.price ?? 0).toStringAsFixed(2)}'),
          if (sub.isRecurring && sub.status == 'Active') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancel(sub),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: Text(l10n.cancelSubscription),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _subscribeCta(dynamic colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.lock_open_rounded,
                  size: 40, color: AppColors.primaryColor1),
              const SizedBox(height: 10),
              Text(l10n.subscribeToUnlock,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                l10n.subscribeToUnlockBody,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: colors.subFg, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                      context, SubscriptionScreen.routeName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l10n.subscribeAndPay,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(dynamic colors, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor1),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: colors.subFg, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: colors.fg, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _paymentRow(MySubTxn t, dynamic colors) {
    return Container(
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
              Text(subStatusLabel(l10n, t.status),
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              if (t.billedAt != null)
                Text(_fmt.format(t.billedAt!),
                    style: TextStyle(color: colors.mutedFg, fontSize: 11)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${t.currency} ${t.amount.toStringAsFixed(2)}',
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            if (t.cardLast4 != null)
              Text('···${t.cardLast4}',
                  style: TextStyle(color: colors.mutedFg, fontSize: 11)),
          ],
        ),
      ]),
    );
  }
}
