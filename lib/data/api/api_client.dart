import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // FIX: sebelumnya baseUrl hardcode ke 'http://localhost:3000/api' padahal
  // komentar di baris ini sendiri mengklaim sudah diperbaiki ke port 5001 —
  // klaim dan kode tidak sinkron. Backend berjalan di PORT=5001 (lihat
  // .env.example), dan 'localhost' tidak bisa diakses dari Android emulator
  // (harus 10.0.2.2) maupun dari device fisik (harus IP LAN komputer).
  //
  // Sekarang baseUrl dipilih otomatis sesuai platform. Untuk device fisik,
  // override _physicalDeviceHost dengan IP LAN komputer development Anda.
  static const int _port = 5001;
  static const String _physicalDeviceHost = 'YOUR_LAN_IP'; // contoh: 192.168.1.44

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$_port/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_port/api'; // Android emulator
    if (Platform.isIOS) return 'http://localhost:$_port/api'; // iOS simulator
    return 'http://$_physicalDeviceHost:$_port/api'; // fallback: device fisik / platform lain
  }

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
