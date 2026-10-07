import '../api/api_client.dart';
import '../model/hotel_model.dart';

/// Repository: RecommendationRepository
/// Data "Recommended for you" — personalized kalau login (backend pakai
/// wishlist+history+preferences sebagai query pgvector), trending kalau guest.
/// Tidak ada endpoint terpisah untuk guest/login: backend yang menentukan
/// berdasarkan ada tidaknya token, jadi repository ini tetap satu method saja.
///
/// F.4: BE juga mengembalikan `profile` (null untuk guest/user baru).
/// `getRecommendations` tetap kembalikan list (backward compat),
/// `getRecommendationsWithProfile` kembalikan record (hotels, profile).
class RecommendationRepository {
  Future<List<HotelModel>> getRecommendations({int limit = 6}) async {
    final r = await getRecommendationsWithProfile(limit: limit);
    return r.hotels;
  }

  Future<({List<HotelModel> hotels, Map<String, dynamic>? profile})>
      getRecommendationsWithProfile({int limit = 6}) async {
    final res = await ApiClient.get('/recommendations', params: {'limit': limit});
    final data = res.data['data'] as List;
    final profile = res.data['profile'] is Map
        ? Map<String, dynamic>.from(res.data['profile'] as Map)
        : null;
    return (
      hotels: data.map((h) => HotelModel.fromJson(h as Map<String, dynamic>)).toList(),
      profile: profile,
    );
  }
}
