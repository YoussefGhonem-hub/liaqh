import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/auth_models.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  AuthProvider(this._repo) {
    _restoreUser();
  }

  AuthResult? _currentUser;

  Future<void> _restoreUser() async {
    _currentUser = await _repo.getSavedUser();
    if (_currentUser != null) notifyListeners();
  }
  bool _loading = false;
  String? _error;

  AuthResult? get currentUser => _currentUser;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isCoach => _currentUser?.isCoach ?? false;
  bool get isGymAdmin => _currentUser?.isGymAdmin ?? false;
  bool get isTrainee => _currentUser?.isTrainee ?? false;
  bool get isPlatformOwner => _currentUser?.isPlatformOwner ?? false;

  /// An individual (personal-gym) coach may create their own trainees. Coaches
  /// inside a managed gym cannot — the gym admin creates trainees for them.
  bool get canCreateTrainees =>
      isCoach && (_currentUser?.isPersonalGym ?? false);

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _repo.login(LoginRequest(email: email, password: password));
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  Future<bool> registerIndividualCoach(RegisterIndividualCoachRequest req) async {
    _setLoading(true);
    try {
      _currentUser = await _repo.registerIndividualCoach(req);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  Future<bool> registerGym({
    required String gymName,
    required String adminEmail,
    required String adminPassword,
    required String adminFirstName,
    required String adminLastName,
    String? adminPhone,
    File? logo,
  }) async {
    _setLoading(true);
    try {
      final result = await _repo.registerGym(
        gymName: gymName,
        adminEmail: adminEmail,
        adminPassword: adminPassword,
        adminFirstName: adminFirstName,
        adminLastName: adminLastName,
        adminPhone: adminPhone,
        logo: logo,
      );
      _currentUser = result.admin;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  Future<bool> registerCoach(RegisterCoachRequest req) async {
    _setLoading(true);
    try {
      _currentUser = await _repo.registerCoach(req);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? preferredLanguage,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _repo.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        preferredLanguage: preferredLanguage,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  /// Upload a new profile image for the current user. The repository compresses
  /// it before upload and updates the cached user, so the avatar refreshes
  /// everywhere immediately. Returns true on success.
  Future<bool> uploadProfileImage(File file) async {
    _setLoading(true);
    try {
      _currentUser = await _repo.uploadProfileImage(file);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Could not upload image. Please try again.');
      return false;
    }
  }

  /// Change the logged-in user's password. Returns true on success.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parseChangePasswordError(e));
      return false;
    }
  }

  String _parseChangePasswordError(dynamic e) {
    // Surface the backend's specific message when available
    // (e.g. "Current password is incorrect.").
    final msg = e.toString();
    final match =
        RegExp(r'"(?:message|detail|title)"\s*:\s*"([^"]+)"').firstMatch(msg);
    if (match != null) return match.group(1)!;
    if (msg.contains('incorrect')) return 'Current password is incorrect.';
    if (msg.contains('400')) return 'Please check your input and try again.';
    if (msg.contains('401')) return 'Session expired. Please log in again.';
    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return 'Cannot connect to server. Check your network.';
    }
    return 'Could not change password. Please try again.';
  }

  Future<void> logout() async {
    await _repo.logout();
    _currentUser = null;
    notifyListeners();
  }

  /// Permanently deletes the current account. On success the user is signed out.
  Future<bool> deleteAccount() async {
    _setLoading(true);
    try {
      await _repo.deleteAccount();
      _currentUser = null;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> checkLoginStatus() => _repo.isLoggedIn();

  void _setLoading(bool v) {
    _loading = v;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _loading = false;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    // Prefer the backend's specific message (e.g. "Phone number already
    // registered.", "Email already registered.") so the user sees what's wrong.
    final backend = _backendMessage(e);
    if (backend != null) return backend;

    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return 'Cannot connect to server. Check your network.';
    }
    if (msg.contains('401')) return 'Unauthorized. Please log in again.';
    if (msg.contains('400')) return 'Invalid data. Please check your inputs.';
    return 'Something went wrong. Please try again.';
  }

  /// Extracts the API error message from a Dio error response, if present.
  String? _backendMessage(dynamic e) {
    try {
      final data = (e as dynamic).response?.data;
      if (data is Map && data['message'] is String) {
        final m = (data['message'] as String).trim();
        if (m.isNotEmpty && m != 'Validation failed') return m;
      }
    } catch (_) {}
    // Fallback: pull "message" out of the stringified error.
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(e.toString());
    final m = match?.group(1)?.trim();
    if (m != null && m.isNotEmpty && m != 'Validation failed') return m;
    return null;
  }
}
