import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'auth_service.dart';

class FileUploadService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8081',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static Future<String?> uploadAudio(String pathOrUrl) async {
    final token = AuthService.token;
    if (token == null || token.isEmpty) return null;

    try {
      FormData formData;

      if (kIsWeb) {
        final blobResponse = await Dio().get<List<int>>(
          pathOrUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final bytes = blobResponse.data!;
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: 'voice.webm'),
        });
      } else {
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            pathOrUrl,
            filename: pathOrUrl.split(RegExp(r'[/\\]')).last,
          ),
        });
      }

      final response = await _dio.post(
        '/api/file/upload',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final result = response.data as Map<String, dynamic>;
      final code = result['code'] as int?;
      if (code == 200) {
        return result['data'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('uploadAudio error: $e');
      return null;
    }
  }
}
