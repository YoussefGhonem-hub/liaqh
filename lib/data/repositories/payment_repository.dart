import 'package:fitnessapp/data/models/payment_models.dart';
import 'package:fitnessapp/data/services/api_service.dart';

class PaymentRepository {
  final ApiService _api;

  PaymentRepository(this._api);

  Future<CheckoutResult> createCheckout() async {
    final resp = await _api.post('/payments/checkout');
    return CheckoutResult.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<CheckoutStatus> getCheckoutStatus(String sessionId) async {
    final resp = await _api.get('/payments/checkout/$sessionId/status');
    return CheckoutStatus.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MySubscription> getMySubscription() async {
    final resp = await _api.get('/payments/my-subscription');
    return MySubscription.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<SubscriptionAccess> getAccess() async {
    final resp = await _api.get('/payments/access');
    return SubscriptionAccess.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<PaymentSubscription>> getSubscriptions() async {
    final resp = await _api.get('/payments/subscriptions');
    final list = resp.data as List<dynamic>;
    return list
        .map((e) => PaymentSubscription.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelSubscription(String paddleSubscriptionId) async {
    await _api.delete('/payments/subscriptions/$paddleSubscriptionId');
  }
}
