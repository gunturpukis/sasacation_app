import '../api/api_client.dart';
import '../model/hotel_model.dart';

/// Repository: RecommendationRepository
/// Data "Recommended for you" — personalized kalau login (backend pakai
/// wishlist+history+preferences sebagai query pgvector), trending kalau guest.
/// Tidak ada endpoint terpisah untuk guest/login: backend yang menentukan
/// berdasarkan ada tidaknya token, jadi repository ini tetap satu method saja.
class RecommendationRepository {
  Future<List<HotelModel>> getRecommendations({int limit = 6}) async {
    final res = await ApiClient.get('/recommendations', params: {'limit': limit});
    final data = res.data['data'] as List;
    return data.map((h) => HotelModel.fromJson(h as Map<String, dynamic>)).toList();
  }
}
