import 'package:dio/dio.dart';
import 'package:sasacation/utils/money.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';

/// F5: pengaturan user tersimpan di server (GET/PUT /api/settings, parsial).
/// Cache lokal dipakai agar layar lain (mis. kartu AI Pick di search) bisa
/// membaca preferensi tanpa request jaringan di setiap build.
class SettingsRepository {
  static const localAiKey = 'ai_personalization';

  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final res = await ApiClient.get('/settings');
      final data = Map<String, dynamic>.from(res.data['data'] as Map);
      // Sinkronkan cache lokal untuk konsumen sinkron.
      final prefs = await SharedPreferences.getInstance();
      if (data['ai_personalization'] is bool) {
        await prefs.setBool(localAiKey, data['ai_personalization'] as bool);
      }
      if (data['language'] is String) {
        await prefs.setString('language', data['language'] as String);
      }
      // F14: kurs global dari kontrak settings (tolerant — absen = mode USD).
      final rateRaw = data['usd_to_idr_rate'];
      final rate = rateRaw is num
          ? rateRaw.toDouble()
          : double.tryParse('$rateRaw');
      if (rate != null && rate > 0) {
        ForexService.setRate(rate);
      }
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Update parsial — hanya field non-null yang dikirim.
  Future<Map<String, dynamic>> updateSettings({
    bool? pushEnabled,
    bool? aiPersonalization,
    String? language,
  }) async {
    try {
      final res = await ApiClient.put('/settings', data: {
        if (pushEnabled != null) 'push_enabled': pushEnabled,
        if (aiPersonalization != null)
          'ai_personalization': aiPersonalization,
        if (language != null) 'language': language,
      });
      final data =
          Map<String, dynamic>.from(res.data['data'] as Map? ?? {});
      if (aiPersonalization != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(localAiKey, aiPersonalization);
      }
      if (language != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language', language);
      }
      return {'success': true, 'settings': data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal menyimpan pengaturan',
      };
    }
  }

  /// Ubah password via backend (F5: POST /api/auth/change-password, min 8).
  /// Menggantikan jalur Firebase langsung agar satu pintu dengan server.
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ApiClient.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal mengubah password',
      };
    }
  }
}
