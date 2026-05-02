import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8081',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  static Dio get dio => _dio;

  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(e.response?.data?['message'] ?? e.message ?? '请求失败');
      }
      throw ApiException(e.message ?? '网络连接失败');
    }
  }

  static Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
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
