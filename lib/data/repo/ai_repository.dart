import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../model/ai_model.dart';

class AiRepository {
  // ─── 1. Chat ─────────────────────────────────────────────────────────────
  // PERUBAHAN: sekarang kirim & terima sessionId, supaya backend tahu ini
  // sambungan dari percakapan yang mana (untuk persist ke chat_messages).
  // sessionId null di call pertama = backend akan buat sesi baru otomatis.
  Future<Map<String, dynamic>> sendMessage(
    List<ChatMessage> messages, {
    String? sessionId,
  }) async {
    try {
      final res = await ApiClient.post('/ai/chat',
          data: {
            'messages': messages.map((m) => m.toJson()).toList(),
            'sessionId': ?sessionId,
          },
          // Ollama lokal bisa butuh puluhan detik untuk generate reply,
          // jauh lebih lambat dari API cloud — default 10s tidak cukup.
          timeout: const Duration(seconds: 90));
      return {
        'success': true,
        'reply': res.data['data']['reply'] as String,
        // null kalau guest (backend tidak buat sesi untuk user belum login)
        'sessionId': res.data['data']['sessionId'] as String?,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout
            ? 'AI sedang lama merespons (timeout). Coba lagi sebentar lagi.'
            : (e.response?.data?['message'] ?? 'AI tidak tersedia saat ini'),
      };
    }
  }

  // ─── 1b. Restore riwayat chat terakhir ──────────────────────────────────
  // Dipanggil sekali saat AiBloc dibuat (app startup) supaya chat dengan Sasa
  // tidak "amnesia" tiap buka app. Hanya berlaku untuk user yang login —
  // guest tidak punya riwayat tersimpan di server.
  Future<Map<String, dynamic>> fetchLatestSession() async {
    try {
      final res = await ApiClient.get('/chat/sessions/latest');
      final data = res.data['data'];
      if (data == null) {
        return {'success': true, 'sessionId': null, 'messages': <ChatMessage>[]};
      }
      final messages = (data['messages'] as List)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
      return {
        'success': true,
        'sessionId': data['sessionId'] as String,
        'messages': messages,
      };
    } on DioException catch (_) {
      // Gagal restore (offline, belum login, dll) → bukan fatal, AiBloc
      // cukup mulai dari AiInitial seperti biasa
      return {'success': false, 'sessionId': null, 'messages': <ChatMessage>[]};
    }
  }

  // ─── 2. Smart Search ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> smartSearch(String query) async {
    try {
      final res = await ApiClient.post('/ai/search',
          data: {'query': query}, timeout: const Duration(seconds: 60));
      return {
        'success': true,
        'result': SmartSearchResult.fromJson(res.data['data']),
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout
            ? 'AI sedang lama merespons (timeout). Coba lagi sebentar lagi.'
            : (e.response?.data?['message'] ?? 'Search gagal'),
      };
    }
  }

  // ─── 3. Generate Description ──────────────────────────────────────────────
  Future<Map<String, dynamic>> generateDescription({
    required String type,
    required String name,
    required String location,
    List<String>? amenities,
    double? price,
    double? rating,
  }) async {
    try {
      final res = await ApiClient.post('/ai/generate-description', data: {
        'type': type,
        'name': name,
        'location': location,
        'amenities': ?amenities,
        'price': ?price,
        'rating': ?rating,
      });
      return {
        'success': true,
        'description': res.data['data']['description'] as String,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal generate deskripsi',
      };
    }
  }

  // ─── 4. Trip Planner ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> generateTripPlan({
    required int duration,
    required double budget,
    required List<String> interests,
    String? startDate,
    String? groupType,
  }) async {
    try {
      final res = await ApiClient.post('/ai/trip-plan',
          data: {
            'duration': duration,
            'budget': budget,
            'interests': interests,
            'startDate': ?startDate,
            'groupType': ?groupType,
          },
          // Itinerary JSON panjang — paling lambat dari semua fitur AI.
          // Terukur bisa 120-150 detik+ pada Ollama lokal (CPU/GPU consumer),
          // kasih ruang timeout paling lega.
          timeout: const Duration(seconds: 180));
      return {
        'success': true,
        'plan': TripPlan.fromJson(res.data['data']),
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout
            ? 'AI sedang lama merespons (timeout). Coba kurangi durasi trip atau coba lagi.'
            : (e.response?.data?['message'] ?? 'Gagal membuat trip plan'),
      };
    }
  }
}
