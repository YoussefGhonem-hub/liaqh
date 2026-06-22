import 'dart:io';
import 'package:dio/dio.dart';
import '../models/coach_profile_models.dart';
import '../services/api_service.dart';

class CoachProfileRepository {
  final ApiService _api;
  CoachProfileRepository(this._api);

  Future<CoachProfile> getProfile(String coachUserId) async {
    final res = await _api.get('/coach-profile/$coachUserId');
    return CoachProfile.fromJson(res.data);
  }

  Future<CoachProfile> getMine() async {
    final res = await _api.get('/coach-profile/me');
    return CoachProfile.fromJson(res.data);
  }

  Future<void> updateProfile({
    String? headline,
    String? bio,
    int? yearsOfExperience,
    String? specialties,
    String? instagramUrl,
    String? whatsappNumber,
    String? specializationNotes,
  }) =>
      _api.put('/coach-profile/me', data: {
        'headline': headline,
        'bio': bio,
        'yearsOfExperience': yearsOfExperience,
        'specialties': specialties,
        'instagramUrl': instagramUrl,
        'whatsappNumber': whatsappNumber,
        'specializationNotes': specializationNotes,
      });

  /// Uploads an image (cert / before / after) and returns its URL.
  Future<String> uploadImage(File file) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path,
          filename: file.path.split(RegExp(r'[/\\]')).last),
    });
    final res = await _api.uploadFile('/coach-profile/upload-image', form);
    return res.data['url'] as String;
  }

  Future<void> addCertification(
          {required String title, String? issuer, int? year, String? imageUrl}) =>
      _api.post('/coach-profile/certifications', data: {
        'title': title,
        'issuer': issuer,
        'year': year,
        'imageUrl': imageUrl,
      });

  Future<void> deleteCertification(String id) =>
      _api.delete('/coach-profile/certifications/$id');

  Future<void> addTransformation({
    String? beforeImageUrl,
    String? afterImageUrl,
    String? caption,
    String? durationText,
  }) =>
      _api.post('/coach-profile/transformations', data: {
        'beforeImageUrl': beforeImageUrl,
        'afterImageUrl': afterImageUrl,
        'caption': caption,
        'durationText': durationText,
      });

  Future<void> deleteTransformation(String id) =>
      _api.delete('/coach-profile/transformations/$id');

  /// Uploads a PDF/document and records it on the profile.
  Future<void> uploadFile(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split(RegExp(r'[/\\]')).last),
    });
    await _api.postForm('/coach-profile/files', formData: form);
  }

  Future<void> deleteFile(String id) => _api.delete('/coach-profile/files/$id');

  Future<void> upsertReview(
          {required String coachUserId, required int rating, String? comment}) =>
      _api.put('/coach-profile/$coachUserId/review',
          data: {'rating': rating, 'comment': comment});
}
