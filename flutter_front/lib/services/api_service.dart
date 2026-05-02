import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8081',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ))..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AuthService.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

  static Dio get dio => _dio;

  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
        throw ApiException('登录已过期，请重新登录');
      }
      if (e.response != null) {
        throw ApiException(e.response?.data?['message'] ?? e.message ?? '请求失败');
      }
      throw ApiException(e.message ?? '网络连接失败');
    }
  }

  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
        throw ApiException('登录已过期，请重新登录');
      }
      if (e.response != null) {
        throw ApiException(e.response?.data?['message'] ?? e.message ?? '请求失败');
      }
      throw ApiException(e.message ?? '网络连接失败');
    }
  }

  static Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
        throw ApiException('登录已过期，请重新登录');
      }
      if (e.response != null) {
        throw ApiException(e.response?.data?['message'] ?? e.message ?? '请求失败');
      }
      throw ApiException(e.message ?? '网络连接失败');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
