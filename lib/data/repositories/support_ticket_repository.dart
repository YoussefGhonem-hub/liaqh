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

  Future<List<SupportTicketModel>> mine() async {
    final res = await _api.get('/support-tickets/mine');
    return (res.data as List).map((j) => SupportTicketModel.fromJson(j)).toList();
  }

  Future<List<SupportTicketModel>> list({String? status}) async {
    final res = await _api.get('/support-tickets',
        params: status != null ? {'status': status} : null);
    return (res.data as List).map((j) => SupportTicketModel.fromJson(j)).toList();
  }

  Future<SupportTicketDetailModel> detail(String id) async {
    final res = await _api.get('/support-tickets/$id');
    return SupportTicketDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> postMessage(String id, String body) =>
      _api.post('/support-tickets/$id/messages', data: {'body': body});

  Future<void> close(String id) => _api.post('/support-tickets/$id/close');
}
