import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../model/ai_model.dart';

class AiRepository {
  // ─── 1. Chat ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> sendMessage(List<ChatMessage> messages) async {
    try {
      final res = await ApiClient.post('/ai/chat',
          data: {'messages': messages.map((m) => m.toJson()).toList()},
          // Ollama lokal bisa butuh puluhan detik untuk generate reply,
          // jauh lebih lambat dari API cloud — default 10s tidak cukup.
          timeout: const Duration(seconds: 90));
      return {
        'success': true,
        'reply': res.data['data']['reply'] as String,
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
        if (amenities != null) 'amenities': amenities,
        if (price != null) 'price': price,
        if (rating != null) 'rating': rating,
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
            if (startDate != null) 'startDate': startDate,
            if (groupType != null) 'groupType': groupType,
          },
          // Itinerary JSON panjang (2048 token) — paling lambat dari semua
          // fitur AI, kasih ruang timeout paling lega.
          timeout: const Duration(seconds: 120));
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
