import 'package:fitnessapp/data/models/payment_method_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/payment_methods_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/utils/status_l10n.dart';
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
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      context.read<PaymentMethodsProvider>().loadMoreRequests();
    }
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
    final l10n = AppLocalizations.of(context);
    final ok = await context
        .read<PaymentMethodsProvider>()
        .review(r.id, true, status: _status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? l10n.paymentApprovedActivated : l10n.failedGeneric),
        backgroundColor: ok ? AppColors.successColor : AppColors.errorColor,
      ));
    }
  }

  Future<void> _reject(ManualPaymentModel r) async {
    final l10n = AppLocalizations.of(context);
    final noteCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rejectPaymentTitle),
        content: TextField(
          controller: noteCtrl,
          decoration: InputDecoration(labelText: l10n.reasonOptional),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.reject)),
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
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<PaymentMethodsProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text(l10n.dashPaymentRequests,
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
                    label: Text(payRequestStatusLabel(l10n, s)),
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
                ? const LiaqhPageLoader()
                : provider.requests.isEmpty
                    ? Center(
                        child: Text(
                            l10n.noRequestsForStatus(
                                payRequestStatusLabel(l10n, _status)),
                            style: TextStyle(color: colors.subFg)))
                    : RefreshIndicator(
                        onRefresh: () async => _load(),
                        child: ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: provider.requests.length +
                              (provider.requestsHasMore ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i >= provider.requests.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: LiaqhMarkLoader(size: 34),
                              );
                            }
                            return _RequestCard(
                              r: provider.requests[i],
                              colors: colors,
                              statusColor:
                                  _statusColor(provider.requests[i].status),
                              onAccept: () => _accept(provider.requests[i]),
                              onReject: () => _reject(provider.requests[i]),
                            );
                          },
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
    final l10n = AppLocalizations.of(context);
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
                child: Text(payRequestStatusLabel(l10n, r.status),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ],
          ),
          Text(r.userEmail, style: TextStyle(color: colors.subFg, fontSize: 12)),
          const SizedBox(height: 10),
          _row(colors, l10n.methodLabel, r.methodCode),
          _row(colors, l10n.accountNameLabel, r.fullAccountName),
          _row(colors, l10n.accountLabel, r.accountIdentifier),
          if (r.referenceNumber != null && r.referenceNumber!.isNotEmpty)
            _row(colors, l10n.referenceLabel, r.referenceNumber!),
          _row(colors, l10n.amount, 'EGP ${r.amount.toStringAsFixed(0)}'),
          _row(colors, l10n.submittedLabel, fmt.format(r.createdAt.toLocal())),
          if (r.reviewNote != null && r.reviewNote!.isNotEmpty)
            _row(colors, l10n.noteLabel, r.reviewNote!),
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
                    child: Text(l10n.reject),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successColor,
                        foregroundColor: Colors.white),
                    child: Text(l10n.accept),
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
