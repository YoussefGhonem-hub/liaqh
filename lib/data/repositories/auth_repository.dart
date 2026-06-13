import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/auth_models.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _api;
  AuthRepository(this._api);

  Future<AuthResult?> getSavedUser() async {
    final json = await _api.getSavedUser();
    if (json == null) return null;
    try {
      return AuthResult.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<AuthResult> login(LoginRequest req) async {
    final res = await _api.post('/auth/login', data: req.toJson());
    final result = AuthResult.fromJson(res.data);
    await _api.saveToken(result.token);
    await _api.saveUser(jsonEncode(result.toJson()));
    return result;
  }

  Future<AuthResult> registerIndividualCoach(RegisterIndividualCoachRequest req) async {
    final res = await _api.post('/auth/register/individual-coach', data: req.toJson());
    final result = AuthResult.fromJson(res.data);
    await _api.saveToken(result.token);
    await _api.saveUser(jsonEncode(result.toJson()));
    return result;
  }

  /// Gym registration with optional logo image file.
  Future<RegisterGymResult> registerGym({
    required String gymName,
    required String adminEmail,
    required String adminPassword,
    required String adminFirstName,
    required String adminLastName,
    String currency = 'EGP',
    String timeZone = 'Africa/Cairo',
    String defaultLanguage = 'ar',
    String? adminPhone,
    File? logo,
  }) async {
    final formData = FormData.fromMap({
      'gymName': gymName,
      'adminEmail': adminEmail,
      'adminPassword': adminPassword,
      'adminFirstName': adminFirstName,
      'adminLastName': adminLastName,
      'currency': currency,
      'timeZone': timeZone,
      'defaultLanguage': defaultLanguage,
      if (adminPhone != null) 'adminPhone': adminPhone,
      if (logo != null)
        'logo': await MultipartFile.fromFile(logo.path,
            filename: logo.path.split('/').last),
    });

    final res = await _api.postForm('/auth/register/gym', formData: formData);
    final result = RegisterGymResult.fromJson(res.data);
    await _api.saveToken(result.admin.token);
    await _api.saveUser(jsonEncode(result.admin.toJson()));
    return result;
  }

  Future<AuthResult> registerCoach(RegisterCoachRequest req) async {
    final res = await _api.post('/auth/register/coach', data: req.toJson());
    final result = AuthResult.fromJson(res.data);
    await _api.saveToken(result.token);
    await _api.saveUser(jsonEncode(result.toJson()));
    return result;
  }

  Future<AuthResult> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? preferredLanguage,
  }) async {
    final res = await _api.patch('/auth/profile', data: {
      'firstName': firstName,
      'lastName': lastName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
    });
    // Server returns UpdateProfileResult; reconstruct minimal AuthResult for cache update
    final data = res.data as Map<String, dynamic>;
    final saved = await getSavedUser();
    final updated = AuthResult(
      token: saved?.token ?? '',
      refreshToken: saved?.refreshToken ?? '',
      userId: saved?.userId ?? '',
      role: saved?.role ?? '',
      fullName: data['fullName'] ?? '${data['firstName']} ${data['lastName']}'.trim(),
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? saved?.email ?? '',
      gymId: saved?.gymId ?? '',
      tenantId: saved?.tenantId,
      isPersonalGym: saved?.isPersonalGym ?? false,
      gymLogoUrl: saved?.gymLogoUrl,
      profileImageUrl: saved?.profileImageUrl,
    );
    await _api.saveUser(jsonEncode(updated.toJson()));
    return updated;
  }

  /// Compresses the picked image (resize to max 512px, JPEG q75 — typically a
  /// few tens of KB) then uploads it. Updates the cached user so the new avatar
  /// shows immediately without re-login. Returns the updated user.
  Future<AuthResult> uploadProfileImage(File file) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 512,
      minHeight: 512,
      quality: 75,
      format: CompressFormat.jpeg,
    );

    final MultipartFile multipart;
    if (compressed != null) {
      multipart = MultipartFile.fromBytes(compressed, filename: 'profile.jpg');
    } else {
      // Fallback: upload the original if compression is unsupported on device.
      multipart = await MultipartFile.fromFile(file.path,
          filename: file.path.split(RegExp(r'[/\\]')).last);
    }

    final formData = FormData.fromMap({'image': multipart});
    final res = await _api.uploadFile('/auth/profile-image', formData);
    final url = (res.data as Map<String, dynamic>)['profileImageUrl'] as String?;

    final saved = await getSavedUser();
    final updated = AuthResult(
      token: saved?.token ?? '',
      refreshToken: saved?.refreshToken,
      userId: saved?.userId ?? '',
      role: saved?.role ?? '',
      fullName: saved?.fullName ?? '',
      firstName: saved?.firstName ?? '',
      lastName: saved?.lastName ?? '',
      email: saved?.email ?? '',
      gymId: saved?.gymId ?? '',
      tenantId: saved?.tenantId,
      isPersonalGym: saved?.isPersonalGym ?? false,
      gymLogoUrl: saved?.gymLogoUrl,
      profileImageUrl: url ?? saved?.profileImageUrl,
    );
    await _api.saveUser(jsonEncode(updated.toJson()));
    return updated;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.post('/auth/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> logout() async {
    await _api.clearToken();
    await _api.clearUser();
  }
  Future<bool> isLoggedIn() => _api.isLoggedIn();
}
