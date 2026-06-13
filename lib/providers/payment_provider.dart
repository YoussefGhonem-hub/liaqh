import 'package:fitnessapp/data/models/payment_models.dart';
import 'package:fitnessapp/data/repositories/payment_repository.dart';
import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repo;

  PaymentProvider(this._repo);

  List<PaymentSubscription> subscriptions = [];
  bool loading = false;
  String? error;

  CheckoutResult? pendingCheckout;
  bool checkoutLoading = false;

  // ── Current subscription detail ───────────────────────────────────────────
  MySubscription? mySubscription;
  bool mySubLoading = false;

  Future<void> loadMySubscription() async {
    mySubLoading = true;
    notifyListeners();
    try {
      mySubscription = await _repo.getMySubscription();
    } catch (e) {
      error = e.toString();
    } finally {
      mySubLoading = false;
      notifyListeners();
    }
  }

  // ── Subscription access / gating ──────────────────────────────────────────
  SubscriptionAccess? access;
  bool accessLoaded = false;

  bool get mustSubscribe => access?.mustSubscribe ?? false;
  bool get premiumLocked => access?.premiumLocked ?? false;
  bool get hasActiveSubscription => access?.hasActiveSubscription ?? false;
  bool get isPaymentRequired => access?.isPaymentRequired ?? false;
  bool get paidPlatform => access?.paidPlatform ?? false;
  bool get paidCoach => access?.paidCoach ?? false;

  /// Loads the gating flags. Safe to call on every dashboard entry.
  Future<void> loadAccess() async {
    try {
      access = await _repo.getAccess();
    } catch (_) {
      // On failure, fail OPEN (don't lock users out due to a network blip).
      access ??= SubscriptionAccess(
          isPaymentRequired: false, hasActiveSubscription: true);
    } finally {
      accessLoaded = true;
      notifyListeners();
    }
  }

  Future<CheckoutResult?> startCheckout() async {
    checkoutLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.createCheckout();
      pendingCheckout = result;
      return result;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      checkoutLoading = false;
      notifyListeners();
    }
  }

  Future<CheckoutStatus?> pollCheckoutStatus(String sessionId) async {
    try {
      return await _repo.getCheckoutStatus(sessionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadSubscriptions() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      subscriptions = await _repo.getSubscriptions();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelSubscription(String paddleSubscriptionId) async {
    try {
      await _repo.cancelSubscription(paddleSubscriptionId);
      await loadSubscriptions();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
