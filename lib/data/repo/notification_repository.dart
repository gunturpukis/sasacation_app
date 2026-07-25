// import 'dart:io' show Platform;
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import '../api/api_client.dart';

// class NotificationRepository {
//   String get _platformName {
//     if (kIsWeb) return 'web';
//     if (Platform.isAndroid) return 'android';
//     if (Platform.isIOS) return 'ios';
//     return 'other';
//   }

//   Future<void> registerToken(String token) async {
//     try {
//       await ApiClient.post('/notifications/register-token', data: {
//         'token': token,
//         'platform': _platformName,
//       });
//     } catch (_) {
//       // Gagal registrasi token tidak boleh menghentikan alur app (mis. saat
//       // login), cukup gagal senyap — token akan dicoba lagi di sesi berikut.
//     }
//   }

//   Future<void> unregisterToken() async {
//     try {
//       await ApiClient.delete('/notifications/token');
//     } catch (_) {}
//   }

//   /// Kirim test push notification. Kalau [token] tidak diisi, backend akan
//   /// pakai FCM token yang sudah terdaftar untuk akun yang sedang login.
//   Future<Map<String, dynamic>> sendTestNotification({
//     String? token,
//     String? title,
//     String? body,
//   }) async {
//     try {
//       final res = await ApiClient.post('/notifications/test', data: {
//         'token': ?token,
//         'title': title ?? 'Test Notifikasi Sasacation',
//         'body': body ?? 'Ini pesan test push notification 🌴',
//       });
//       return {'success': true, 'message': res.data['message']};
//     } on DioException catch (e) {
//       return {'success': false, 'message': e.response?.data?['message'] ?? 'Gagal mengirim test notification'};
//     }
//   }
// }
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../api/api_client.dart';
import '../model/notification_model.dart';
 
class NotificationRepository {
  String get _platformName {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }
 
  /// Riwayat notifikasi in-app — lihat migrateNotifications.js di backend.
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final res = await ApiClient.get('/notifications');
      final list = (res.data['data'] as List)
          .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
          .toList();
      return {
        'success': true,
        'notifications': list,
        'unreadCount': res.data['unreadCount'] as int? ?? 0,
      };
    } on DioException catch (_) {
      return {'success': false, 'notifications': <NotificationModel>[], 'unreadCount': 0};
    }
  }
 
  Future<void> markAsRead(String id) async {
    try {
      await ApiClient.patch('/notifications/$id/read');
    } catch (_) {
      // Gagal tandai terbaca bukan hal kritis — tidak perlu mengganggu UI
    }
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
        'token': ?token,
        'title': title ?? 'Test Notifikasi Sasacation',
        'body': body ?? 'Ini pesan test push notification 🌴',
      });
      return {'success': true, 'message': res.data['message']};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Gagal mengirim test notification'};
    }
  }
}