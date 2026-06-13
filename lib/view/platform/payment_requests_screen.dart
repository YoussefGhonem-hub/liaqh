import 'package:fitnessapp/data/models/payment_method_models.dart';
import 'package:fitnessapp/providers/payment_methods_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Platform Owner: review (accept / reject) manual payment requests.
class PaymentRequestsScreen extends StatefulWidget {
  static const routeName = '/PaymentRequestsScreen';
  const PaymentRequestsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentRequestsScreen> createState() => _PaymentRequestsScreenState();
}

class _PaymentRequestsScreenState extends State<PaymentRequestsScreen> {
  String _status = 'Pending';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() =>
      context.read<PaymentMethodsProvider>().loadRequests(status: _status);

  Color _statusColor(String s) {
    switch (s) {
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _accept(ManualPaymentModel r) async {
    final ok = await context
        .read<PaymentMethodsProvider>()
        .review(r.id, true, status: _status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Payment approved — subscription activated.' : 'Failed.'),
        backgroundColor: ok ? AppColors.successColor : AppColors.errorColor,
      ));
    }
  }

  Future<void> _reject(ManualPaymentModel r) async {
    final noteCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject payment?'),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(labelText: 'Reason (optional)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reject')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<PaymentMethodsProvider>().review(r.id, false,
          note: noteCtrl.text.trim(), status: _status);
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
        title: Text('Payment Requests',
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Status filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: ['Pending', 'Accepted', 'Rejected'].map((s) {
                final selected = _status == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: selected,
                    selectedColor: AppColors.primaryColor1,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : colors.fg,
                        fontWeight: FontWeight.w600),
                    backgroundColor: colors.card,
                    onSelected: (_) {
                      setState(() => _status = s);
                      _load();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: provider.loading && provider.requests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.requests.isEmpty
                    ? Center(
                        child: Text('No $_status requests.',
                            style: TextStyle(color: colors.subFg)))
                    : RefreshIndicator(
                        onRefresh: () async => _load(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: provider.requests.length,
                          itemBuilder: (_, i) => _RequestCard(
                            r: provider.requests[i],
                            colors: colors,
                            statusColor: _statusColor(provider.requests[i].status),
                            onAccept: () => _accept(provider.requests[i]),
                            onReject: () => _reject(provider.requests[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ManualPaymentModel r;
  final AppThemeColors colors;
  final Color statusColor;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const _RequestCard({
    required this.r,
    required this.colors,
    required this.statusColor,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy · h:mm a');
    return Container(
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
                child: Text(r.userName,
                    style: TextStyle(
                        color: colors.fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(r.status,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ],
          ),
          Text(r.userEmail, style: TextStyle(color: colors.subFg, fontSize: 12)),
          const SizedBox(height: 10),
          _row(colors, 'Method', r.methodCode),
          _row(colors, 'Account name', r.fullAccountName),
          _row(colors, 'Account', r.accountIdentifier),
          if (r.referenceNumber != null && r.referenceNumber!.isNotEmpty)
            _row(colors, 'Reference', r.referenceNumber!),
          _row(colors, 'Amount', 'EGP ${r.amount.toStringAsFixed(0)}'),
          _row(colors, 'Submitted', fmt.format(r.createdAt.toLocal())),
          if (r.reviewNote != null && r.reviewNote!.isNotEmpty)
            _row(colors, 'Note', r.reviewNote!),
          if (r.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorColor,
                        side: const BorderSide(color: AppColors.errorColor)),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successColor,
                        foregroundColor: Colors.white),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(AppThemeColors colors, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 100,
                child: Text(label,
                    style: TextStyle(color: colors.mutedFg, fontSize: 12.5))),
            Expanded(
              child: Text(value,
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
