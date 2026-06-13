import 'package:flutter/material.dart';
import '../data/models/payment_method_models.dart';
import '../data/repositories/payment_methods_repository.dart';

class PaymentMethodsProvider extends ChangeNotifier {
  final PaymentMethodsRepository _repo;
  PaymentMethodsProvider(this._repo);

  List<PaymentMethodModel> methods = [];
  List<ManualPaymentModel> requests = []; // admin list
  List<ManualPaymentModel> myRequests = []; // trainee list
  int pendingCount = 0; // pending manual requests (for owner badge)
  bool loading = false;
  bool submitting = false;
  String? error;

  // ── Platform settings (owner) ───────────────────────────────────────────────
  bool requireSystemSubscription = true;
  bool settingsLoading = false;

  Future<void> loadPlatformSettings() async {
    settingsLoading = true;
    notifyListeners();
    try {
      requireSystemSubscription = await _repo.getRequireSystemSubscription();
    } catch (_) {}
    settingsLoading = false;
    notifyListeners();
  }

  Future<bool> setRequireSystemSubscription(bool value) async {
    final previous = requireSystemSubscription;
    requireSystemSubscription = value; // optimistic
    notifyListeners();
    try {
      requireSystemSubscription = await _repo.setRequireSystemSubscription(value);
      notifyListeners();
      // The server switches all methods off when the system subscription is
      // disabled — refresh so the toggles reflect the new state.
      await loadMethods(all: true);
      return true;
    } catch (e) {
      requireSystemSubscription = previous; // revert on failure
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Lightweight count of pending requests for the owner's bottom-bar badge.
  Future<void> loadPendingCount() async {
    try {
      final list = await _repo.list(status: 'Pending');
      pendingCount = list.length;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadMethods({bool all = false}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      methods = all ? await _repo.getAll() : await _repo.getActive();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMethod(String id,
      {bool? isActive, String? receiverNumber, String? instructions, String? name}) async {
    try {
      await _repo.updateMethod(id,
          isActive: isActive,
          receiverNumber: receiverNumber,
          instructions: instructions,
          name: name);
      await loadMethods(all: true);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> submit({
    required String methodCode,
    required String fullAccountName,
    required String accountIdentifier,
    String? referenceNumber,
  }) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _repo.submit(
        methodCode: methodCode,
        fullAccountName: fullAccountName,
        accountIdentifier: accountIdentifier,
        referenceNumber: referenceNumber,
      );
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<void> loadMyRequests() async {
    try {
      myRequests = await _repo.mine();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> loadRequests({String? status}) async {
    loading = true;
    notifyListeners();
    try {
      requests = await _repo.list(status: status);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> review(String id, bool accept, {String? note, String? status}) async {
    try {
      await _repo.review(id, accept, note: note);
      await loadRequests(status: status);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
