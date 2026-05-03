import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _usernameKey = 'username';
  static const _avatarUrlKey = 'avatar_url';

  static String? get token => _cachedToken;
  static int? get userId => _cachedUserId;
  static String? get username => _cachedUsername;
  static String? get avatarUrl => _cachedAvatarUrl;

  static String? _cachedToken;
  static int? _cachedUserId;
  static String? _cachedUsername;
  static String? _cachedAvatarUrl;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    _cachedUserId = prefs.getInt(_userIdKey);
    _cachedUsername = prefs.getString(_usernameKey);
    _cachedAvatarUrl = prefs.getString(_avatarUrlKey);
  }

  static bool get isLoggedIn => _cachedToken != null && _cachedToken!.isNotEmpty;

  static Future<Map<String, dynamic>> _checkResult(Map<String, dynamic> result) async {
    final code = result['code'] as int?;
    if (code == null || code != 200) {
      throw ApiException(result['message'] ?? '请求失败');
    }
    return result;
  }

  static Future<Map<String, dynamic>> register(String username, String password) async {
    final result = await ApiService.post('/api/user/register', data: {
      'username': username,
      'password': password,
    });
    return _checkResult(result);
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await ApiService.post('/api/user/login', data: {
      'username': username,
      'password': password,
    });

    await _checkResult(result);

    final data = result['data'] as Map<String, dynamic>?;
    if (data != null) {
      await _saveToken(
        token: data['token'],
        userId: data['userId'],
        username: data['username'],
        avatarUrl: data['avatarUrl'],
      );
    }
    return result;
  }

  static Future<void> _saveToken({
    required String token,
    required int userId,
    required String username,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    if (avatarUrl != null) {
      await prefs.setString(_avatarUrlKey, avatarUrl);
    }
    _cachedToken = token;
    _cachedUserId = userId;
    _cachedUsername = username;
    _cachedAvatarUrl = avatarUrl;
  }

  static Future<void> updateLocalProfile({String? username, String? avatarUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    if (username != null) {
      await prefs.setString(_usernameKey, username);
      _cachedUsername = username;
    }
    if (avatarUrl != null) {
      await prefs.setString(_avatarUrlKey, avatarUrl);
      _cachedAvatarUrl = avatarUrl;
    }
  }

  static Future<String?> uploadAvatar(Uint8List bytes, {String filename = 'avatar.jpg'}) async {
    final token = AuthService.token;
    if (token == null || token.isEmpty) return null;

    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://localhost:8081',
        connectTimeout: const Duration(seconds: 30),
      ));

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await dio.post(
        '/api/user/avatar',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final result = response.data as Map<String, dynamic>;
      final code = result['code'] as int?;
      if (code == 200) {
        final url = result['data'] as String?;
        if (url != null) {
          await updateLocalProfile(avatarUrl: url);
        }
        return url;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateProfile({String? username, String? avatarUrl}) async {
    final result = await ApiService.put('/api/user/profile', data: {
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    });

    final code = result['code'] as int?;
    if (code != 200) {
      throw ApiException(result['message'] ?? '更新资料失败');
    }

    final data = result['data'] as Map<String, dynamic>?;
    if (data != null) {
      await _saveToken(
        token: data['token'] ?? _cachedToken ?? '',
        userId: data['userId'] ?? _cachedUserId ?? 0,
        username: data['username'] ?? _cachedUsername ?? '',
        avatarUrl: data['avatarUrl'],
      );
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_avatarUrlKey);
    _cachedToken = null;
    _cachedUserId = null;
    _cachedUsername = null;
    _cachedAvatarUrl = null;
  }
}
