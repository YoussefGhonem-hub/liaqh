import '../models/payment_method_models.dart';
import '../services/api_service.dart';

class PaymentMethodsRepository {
  final ApiService _api;
  PaymentMethodsRepository(this._api);

  // ── Payment methods ─────────────────────────────────────────────────────────
  Future<List<PaymentMethodModel>> getActive() async {
    final res = await _api.get('/payment-methods');
    return (res.data as List).map((j) => PaymentMethodModel.fromJson(j)).toList();
  }

  Future<List<PaymentMethodModel>> getAll() async {
    final res = await _api.get('/payment-methods/all');
    return (res.data as List).map((j) => PaymentMethodModel.fromJson(j)).toList();
  }

  Future<void> updateMethod(
    String id, {
    bool? isActive,
    String? name,
    String? receiverNumber,
    String? instructions,
  }) =>
      _api.patch('/payment-methods/$id', data: {
        if (isActive != null) 'isActive': isActive,
        if (name != null) 'name': name,
        if (receiverNumber != null) 'receiverNumber': receiverNumber,
        if (instructions != null) 'instructions': instructions,
      });

  // ── Manual payment requests ─────────────────────────────────────────────────
  Future<String> submit({
    required String methodCode,
    required String fullAccountName,
    required String accountIdentifier,
    String? referenceNumber,
  }) async {
    final res = await _api.post('/payment-requests', data: {
      'methodCode': methodCode,
      'fullAccountName': fullAccountName,
      'accountIdentifier': accountIdentifier,
      if (referenceNumber != null && referenceNumber.isNotEmpty)
        'referenceNumber': referenceNumber,
    });
    return res.data['id'].toString();
  }

  Future<List<ManualPaymentModel>> mine() async {
    final res = await _api.get('/payment-requests/mine');
    return (res.data as List).map((j) => ManualPaymentModel.fromJson(j)).toList();
  }

  Future<List<ManualPaymentModel>> list({String? status}) async {
    final res = await _api.get('/payment-requests',
        params: status != null ? {'status': status} : null);
    return (res.data as List).map((j) => ManualPaymentModel.fromJson(j)).toList();
  }

  Future<void> review(String id, bool accept, {String? note}) =>
      _api.post('/payment-requests/$id/review', data: {
        'accept': accept,
        if (note != null && note.isNotEmpty) 'note': note,
      });

  // ── Platform settings ───────────────────────────────────────────────────────
  Future<bool> getRequireSystemSubscription() async {
    final res = await _api.get('/platform-settings');
    return (res.data as Map<String, dynamic>)['requireSystemSubscription']
            as bool? ??
        true;
  }

  Future<bool> setRequireSystemSubscription(bool value) async {
    final res = await _api.patch('/platform-settings',
        data: {'requireSystemSubscription': value});
    return (res.data as Map<String, dynamic>)['requireSystemSubscription']
            as bool? ??
        value;
  }
}
