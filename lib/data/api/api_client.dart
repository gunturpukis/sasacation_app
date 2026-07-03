import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // FIX: backend jalan di port 5001 (lihat log server: "Sasacation API →
  // http://localhost:5001"), sebelumnya di sini ke-hardcode port 3000 —
  // menyebabkan SEMUA request API gagal connect, termasuk AI Smart Search.
  static const String baseUrl = 'http://localhost:5001/api'; // iOS simulator / web
  // static const String baseUrl = 'http://10.0.2.2:5001/api'; // Android emulator
  // static const String baseUrl = 'http://YOUR_LAN_IP:5001/api'; // Physical device (WiFi sama dgn komputer)

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach JWT token ke setiap request
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle 401 - token expired
          if (e.response?.statusCode == 401) {
            // TODO: Redirect ke login
          }
          return handler.next(e);
        },
      ),
    );

  static Dio get instance => _dio;

  // Helper methods
  static Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  static Future<Response> post(String path, {dynamic data, Duration? timeout}) =>
      _dio.post(
        path,
        data: data,
        // Override timeout per-request. Dipakai untuk endpoint AI yang jalan
        // di atas Ollama lokal (bisa 30-90+ detik), jauh lebih lambat dari
        // endpoint biasa (auth, hotels, dst) yang tetap pakai timeout default.
        options: timeout != null
            ? Options(sendTimeout: timeout, receiveTimeout: timeout)
            : null,
      );

  static Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  static Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  static Future<Response> delete(String path) => _dio.delete(path);
}
