import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../api/api_client.dart';

class NotificationRepository {
  String get _platformName {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  Future<void> registerToken(String token) async {
    try {
      await ApiClient.post('/notifications/register-token', data: {
        'token': token,
        'platform': _platformName,
      });
    } catch (_) {
      // Gagal registrasi token tidak boleh menghentikan alur app (mis. saat
      // login), cukup gagal senyap — token akan dicoba lagi di sesi berikut.
    }
  }

  Future<void> unregisterToken() async {
    try {
      await ApiClient.delete('/notifications/token');
    } catch (_) {}
  }

  /// Kirim test push notification. Kalau [token] tidak diisi, backend akan
  /// pakai FCM token yang sudah terdaftar untuk akun yang sedang login.
  Future<Map<String, dynamic>> sendTestNotification({
    String? token,
    String? title,
    String? body,
  }) async {
    try {
      final res = await ApiClient.post('/notifications/test', data: {
        if (token != null) 'token': token,
        'title': title ?? 'Test Notifikasi Sasacation',
        'body': body ?? 'Ini pesan test push notification 🌴',
      });
      return {'success': true, 'message': res.data['message']};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Gagal mengirim test notification'};
    }
  }
}
