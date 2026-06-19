import '../models/paged_result.dart';
import '../models/support_ticket_models.dart';
import '../services/api_service.dart';

class SupportTicketRepository {
  final ApiService _api;
  SupportTicketRepository(this._api);

  Future<String> create({required String subject, required String message}) async {
    final res = await _api.post('/support-tickets',
        data: {'subject': subject, 'message': message});
    return res.data['id'].toString();
  }

  Future<PagedResult<SupportTicketModel>> mine(
      {int page = 1, int pageSize = 20}) async {
    final res = await _api
        .get('/support-tickets/mine', params: {'page': page, 'pageSize': pageSize});
    return PagedResult.fromJson(res.data, (j) => SupportTicketModel.fromJson(j));
  }

  Future<PagedResult<SupportTicketModel>> list(
      {String? status, int page = 1, int pageSize = 20}) async {
    final res = await _api.get('/support-tickets', params: {
      if (status != null) 'status': status,
      'page': page,
      'pageSize': pageSize,
    });
    return PagedResult.fromJson(res.data, (j) => SupportTicketModel.fromJson(j));
  }

  Future<SupportTicketDetailModel> detail(String id) async {
    final res = await _api.get('/support-tickets/$id');
    return SupportTicketDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> postMessage(String id, String body) =>
      _api.post('/support-tickets/$id/messages', data: {'body': body});

  /// Platform Owner edits one of their own replies.
  Future<void> editMessage(String messageId, String body) =>
      _api.put('/support-tickets/messages/$messageId', data: {'body': body});

  Future<void> close(String id) => _api.post('/support-tickets/$id/close');
}
