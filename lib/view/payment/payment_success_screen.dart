import 'package:fitnessapp/data/models/payment_models.dart';
import 'package:fitnessapp/providers/payment_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shown after Paddle confirms payment. Calls the API to refresh the
/// subscription/access state, then displays a confirmation with plan details.
class PaymentSuccessScreen extends StatefulWidget {
  static const routeName = '/PaymentSuccessScreen';

  const PaymentSuccessScreen({Key? key}) : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _refreshing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final pp = context.read<PaymentProvider>();
    // Update subscription + gating from the backend now that payment is done.
    await pp.loadAccess();
    await pp.loadMySubscription();
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pp = context.watch<PaymentProvider>();
    final sub = pp.mySubscription;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.successColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.successColor, size: 64),
              ),
              const SizedBox(height: 28),
              Text(
                'Payment Successful',
                style: TextStyle(
                    color: colors.fg, fontSize: 24, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your membership is now active. Enjoy full access to all features.',
                style: TextStyle(color: colors.mutedFg, fontSize: 15, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (_refreshing)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(),
                )
              else if (sub != null)
                _SummaryCard(colors: colors, sub: sub),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _refreshing
                      ? null
                      : () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                  child: const Text('Continue to App',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final AppThemeColors colors;
  final MySubscription sub;
  const _SummaryCard({required this.colors, required this.sub});

  @override
  Widget build(BuildContext context) {
    final renewDate = sub.nextBillDate ?? sub.endDate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(colors, 'Plan', sub.planName ?? 'Standard'),
          if (sub.price != null) ...[
            const SizedBox(height: 10),
            _row(colors, 'Price',
                '${sub.price!.toStringAsFixed(0)} ${sub.currency}'
                '${sub.billingCycle != null ? ' / ${sub.billingCycle}' : ''}'),
          ],
          if (renewDate != null) ...[
            const SizedBox(height: 10),
            _row(colors, sub.autoRenew ? 'Renews' : 'Valid until',
                renewDate.toString().split(' ').first),
          ],
          if (sub.daysRemaining != null) ...[
            const SizedBox(height: 10),
            _row(colors, 'Days remaining', '${sub.daysRemaining}'),
          ],
        ],
      ),
    );
  }

  Widget _row(AppThemeColors colors, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colors.mutedFg, fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: colors.fg, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
