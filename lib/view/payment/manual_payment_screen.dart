import 'package:fitnessapp/data/models/payment_method_models.dart';
import 'package:fitnessapp/providers/payment_methods_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Manual payment (InstaPay / Wallet): shows the receiver number and a form the
/// trainee fills in. The request is reviewed by the Platform Owner.
class ManualPaymentScreen extends StatefulWidget {
  static const routeName = '/ManualPaymentScreen';
  final PaymentMethodModel method;
  const ManualPaymentScreen({Key? key, required this.method}) : super(key: key);

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();

  bool get _isInstaPay => widget.method.code == 'InstaPay';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _accountCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<PaymentMethodsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final ok = await provider.submit(
      methodCode: widget.method.code,
      fullAccountName: _nameCtrl.text.trim(),
      accountIdentifier: _accountCtrl.text.trim(),
      referenceNumber: _refCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      await provider.loadMyRequests();
      messenger.showSnackBar(const SnackBar(
          content: Text('Payment submitted. We\'ll confirm within 24 hours.'),
          backgroundColor: AppColors.successColor));
      nav.pop(true);
    } else {
      messenger.showSnackBar(SnackBar(
          content: Text(provider.error ?? 'Could not submit payment.'),
          backgroundColor: AppColors.errorColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final submitting = context.watch<PaymentMethodsProvider>().submitting;
    final accountLabel =
        _isInstaPay ? 'InstaPay account (email)' : 'Account number (phone number)';

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text('Pay with ${widget.method.name}',
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Receiver number card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryG),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Send the payment to this ${widget.method.name} number',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(widget.method.receiverNumber ?? '—',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2)),
                        ),
                        IconButton(
                          tooltip: 'Copy',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: widget.method.receiverNumber ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Number copied')));
                          },
                          icon: const Icon(Icons.copy_rounded,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 24h hint
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.warningColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.method.instructions ??
                            'Acceptance of payment may take up to 24 hours.',
                        style: const TextStyle(
                            color: AppColors.warningColor, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text('After sending the money, fill in your details below:',
                  style: TextStyle(color: colors.subFg, fontSize: 13)),
              const SizedBox(height: 16),

              _field(colors, _nameCtrl, 'Full account name',
                  'Name on your account',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              _field(colors, _accountCtrl, accountLabel,
                  _isInstaPay ? 'name@instapay' : '01xxxxxxxxx',
                  keyboardType: _isInstaPay
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              _field(colors, _refCtrl,
                  _isInstaPay ? 'Reference number' : 'Reference number (if found)',
                  'Transaction reference',
                  validator: (v) => (_isInstaPay && (v == null || v.trim().isEmpty))
                      ? 'Required'
                      : null),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Payment',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(AppThemeColors colors, TextEditingController c, String label,
      String hint,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: colors.subFg, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: colors.fg),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.mutedFg),
            filled: true,
            fillColor: colors.card,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
