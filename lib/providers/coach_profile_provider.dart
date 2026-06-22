import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/coach_profile_models.dart';
import '../data/repositories/coach_profile_repository.dart';

class CoachProfileProvider extends ChangeNotifier {
  final CoachProfileRepository _repo;
  CoachProfileProvider(this._repo);

  CoachProfile? _profile;
  bool _loading = false;
  bool _saving = false;
  String? _error;

  CoachProfile? get profile => _profile;
  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;

  Future<void> load(String coachUserId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repo.getProfile(coachUserId);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMine() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repo.getMine();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _saving = true;
    notifyListeners();
    try {
      await action();
      await loadMine();
      _saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _saving = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      return await _repo.uploadImage(file);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateProfile({
    String? headline,
    String? bio,
    int? yearsOfExperience,
    String? specialties,
    String? instagramUrl,
    String? whatsappNumber,
    String? specializationNotes,
  }) =>
      _run(() => _repo.updateProfile(
            headline: headline,
            bio: bio,
            yearsOfExperience: yearsOfExperience,
            specialties: specialties,
            instagramUrl: instagramUrl,
            whatsappNumber: whatsappNumber,
            specializationNotes: specializationNotes,
          ));

  Future<bool> addCertification(
          {required String title, String? issuer, int? year, String? imageUrl}) =>
      _run(() => _repo.addCertification(
          title: title, issuer: issuer, year: year, imageUrl: imageUrl));

  Future<bool> deleteCertification(String id) =>
      _run(() => _repo.deleteCertification(id));

  Future<bool> addTransformation(
          {String? beforeImageUrl,
          String? afterImageUrl,
          String? caption,
          String? durationText}) =>
      _run(() => _repo.addTransformation(
          beforeImageUrl: beforeImageUrl,
          afterImageUrl: afterImageUrl,
          caption: caption,
          durationText: durationText));

  Future<bool> deleteTransformation(String id) =>
      _run(() => _repo.deleteTransformation(id));

  Future<bool> uploadFile(File file) => _run(() => _repo.uploadFile(file));
  Future<bool> deleteFile(String id) => _run(() => _repo.deleteFile(id));

  /// Trainee submits/updates a review for [coachUserId]; reloads that profile.
  Future<bool> submitReview(
      {required String coachUserId, required int rating, String? comment}) async {
    _saving = true;
    notifyListeners();
    try {
      await _repo.upsertReview(
          coachUserId: coachUserId, rating: rating, comment: comment);
      _profile = await _repo.getProfile(coachUserId);
      _saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _saving = false;
      notifyListeners();
      return false;
    }
  }
}
