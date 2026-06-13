import 'dart:io';
import 'package:dio/dio.dart';
import '../models/progress_models.dart';
import '../services/api_service.dart';

class ProgressRepository {
  final ApiService _api;
  ProgressRepository(this._api);

  Future<List<ProgressEntry>> getHistory(String traineeId) async {
    final res = await _api.get('/progress/trainee/$traineeId');
    return (res.data as List).map((j) => ProgressEntry.fromJson(j)).toList();
  }

  Future<String> addEntry(AddProgressRequest req) async {
    final res = await _api.post('/progress', data: req.toJson());
    return res.data['id'].toString();
  }

  Future<String> uploadPhoto(File file, String traineeId) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
    });
    final res = await _api.uploadFile(
        '/progress/upload-photo?traineeId=$traineeId', formData);
    return res.data['url'];
  }

  Future<void> deleteEntry(String id) async {
    await _api.delete('/progress/$id');
  }
}
