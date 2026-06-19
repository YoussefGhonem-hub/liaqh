import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  /// Local dev (debug/profile) talks to the API on the host machine via the
  /// Android emulator loopback. Release/deploy builds talk to the hosted server.
  static const String _localBaseUrl = 'http://10.0.2.2:5000/api';
  static const String _prodBaseUrl =
      'https://ghyoussef-002-site2.ftempurl.com/api';

  static const String baseUrl =  _prodBaseUrl;

  /// Called when the server rejects our token (401) on an authenticated request
  /// — e.g. the password was changed elsewhere and the security stamp no longer
  /// matches. The app wires this to clear state and redirect to the login screen.
  static void Function()? onUnauthorized;
  bool _handlingUnauthorized = false;
  static const _tokenKey = 'jwt_token';
  static const _localeKey = 'app_locale';

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        // Forward current locale for bilingual error messages
        final prefs = await SharedPreferences.getInstance();
        final locale = prefs.getString(_localeKey) ?? 'en';
        options.headers['Accept-Language'] = locale;
        return handler.next(options);
      },
      onError: (e, handler) async {
        final path = e.requestOptions.path;
        final isAuthCall =
            path.contains('/auth/login') || path.contains('/auth/register');
        if (e.response?.statusCode == 401 && !isAuthCall) {
          // Our session is no longer valid (expired or password changed).
          await _storage.delete(key: _tokenKey);
          await _storage.delete(key: _userKey);
          if (!_handlingUnauthorized) {
            _handlingUnauthorized = true;
            onUnauthorized?.call();
            // Allow future redirects after this one settles.
            Future.delayed(const Duration(seconds: 2),
                () => _handlingUnauthorized = false);
          }
        }
        return handler.next(e);
      },
    ));
  }

  static const _userKey = 'cached_user';

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<bool> isLoggedIn() async => (await _storage.read(key: _tokenKey)) != null;

  Future<void> saveUser(String userJson) => _storage.write(key: _userKey, value: userJson);
  Future<String?> getSavedUser() => _storage.read(key: _userKey);
  Future<void> clearUser() => _storage.delete(key: _userKey);

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  Future<Response> postForm(String path, {required FormData formData}) =>
      _dio.post(path, data: formData,
          options: Options(contentType: 'multipart/form-data'));

  Future<Response> uploadFile(String path, FormData formData) =>
      _dio.post(path, data: formData);

  String get fileBaseUrl => baseUrl.replaceAll('/api', '');
}
