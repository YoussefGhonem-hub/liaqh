import 'dart:async';

import 'package:fitnessapp/providers/payment_provider.dart';
import 'package:fitnessapp/view/payment/payment_success_screen.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the Paddle-hosted checkout URL in the device browser.
/// Polls the backend every 3 seconds to detect when payment completes.
class CheckoutLauncherScreen extends StatefulWidget {
  static const routeName = '/CheckoutLauncherScreen';

  final String checkoutUrl;
  final String sessionId;
  final VoidCallback? onSuccess;

  const CheckoutLauncherScreen({
    Key? key,
    required this.checkoutUrl,
    required this.sessionId,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<CheckoutLauncherScreen> createState() => _CheckoutLauncherScreenState();
}

class _CheckoutLauncherScreenState extends State<CheckoutLauncherScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;
  String _status = 'initiated';
  bool _launched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _launchUrl();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.checkoutUrl);
    // Try an external browser first; fall back to an in-app webview. Don't
    // gate on canLaunchUrl — it can wrongly return false on some devices.
    bool ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok) {
      try {
        ok = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {}
    }
    if (!ok) {
      try {
        ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }

    if (ok) {
      setState(() => _launched = true);
      _startPolling();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not open the browser for checkout.'),
      ));
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _check());
  }

  bool _done = false;

  Future<void> _check() async {
    if (_done || !mounted) return;
    final pp = context.read<PaymentProvider>();

    // Completion = either the checkout session is marked completed, OR the
    // subscription is now active (webhook may have activated the membership).
    final status = await pp.pollCheckoutStatus(widget.sessionId);
    await pp.loadAccess();
    if (!mounted) return;

    if (status != null) setState(() => _status = status.status);
    final completed =
        status?.status == 'completed' || pp.hasActiveSubscription;

    if (completed) {
      _done = true;
      _pollTimer?.cancel();
      widget.onSuccess?.call();
      if (mounted) {
        // Replace this screen with a dedicated confirmation page that refreshes
        // the subscription from the API and shows the new plan details.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const PaymentSuccessScreen(),
          ),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user returns from the browser, check immediately (don't wait
    // for the 3s timer) so the subscription updates the moment they're back.
    if (state == AppLifecycleState.resumed) {
      _check();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompleted = _status == 'completed';

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        title: Text('Complete Payment',
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: colors.fg),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryColor1.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.open_in_browser_rounded,
                color: isCompleted
                    ? AppColors.successColor
                    : AppColors.primaryColor1,
                size: 44,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              isCompleted
                  ? 'Payment Complete!'
                  : _launched
                      ? 'Waiting for payment...'
                      : 'Opening checkout...',
              style: TextStyle(
                  color: colors.fg,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isCompleted
                  ? 'Your membership has been activated.'
                  : 'Complete your payment in the browser.\nThis screen will update automatically.',
              style: TextStyle(color: colors.mutedFg, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            if (!isCompleted) ...[
              if (_launched) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.open_in_browser_rounded),
                  label: const Text('Open Checkout Again',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: _launchUrl,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
