import 'dart:io';
import 'package:dio/dio.dart';
import '../models/inbody_models.dart';
import '../services/api_service.dart';

class InBodyRepository {
  final ApiService _api;
  InBodyRepository(this._api);

  Future<List<InBodyMeasurement>> getHistory(String traineeId) async {
    final res = await _api.get('/inbody/trainee/$traineeId');
    return (res.data as List).map((j) => InBodyMeasurement.fromJson(j)).toList();
  }

  Future<String> addMeasurement(AddInBodyRequest req) async {
    final res = await _api.post('/inbody', data: req.toJson());
    return res.data.toString();
  }

  Future<String> uploadScan(File file, String traineeId) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });
    final res = await _api.uploadFile(
        '/inbody/upload-scan?traineeId=$traineeId', formData);
    return res.data['url'];
  }
}
