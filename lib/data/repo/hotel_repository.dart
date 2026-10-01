import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../model/hotel_model.dart';

class HotelRepository {
  // Ambil semua hotel (dengan filter opsional)
  //
  // F3: `amenities` (AND, dipisah koma) dan `sort`
  // (rating|price_asc|price_desc|newest, salah → 400) difilter di server.
  Future<List<HotelModel>> getHotels({
    bool? featured,
    String? search,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await ApiClient.get('/hotels', params: {
        if (featured != null) 'featured': featured.toString(),
        'search': ?search,
        'minPrice': ?minPrice,
        'maxPrice': ?maxPrice,
        if (amenities != null && amenities.isNotEmpty)
          'amenities': amenities.join(','),
        'sort': ?sort,
        'page': page,
        'limit': limit,
      });
      final List data = res.data['data'];
      return data.map((e) => HotelModel.fromJson(e)).toList();
    } on DioException {
      return [];
    }
  }

  // Ambil hotel featured untuk home page
  Future<List<HotelModel>> getFeaturedHotels() => getHotels(featured: true, limit: 5);

  // Detail hotel
  Future<HotelModel?> getHotelById(String id) async {
    try {
      final res = await ApiClient.get('/hotels/$id');
      return HotelModel.fromJson(res.data['data']);
    } catch (_) {
      return null;
    }
  }

  /// Hotel terdekat dari koordinat [lat]/[lng] (biasanya lokasi GPS user),
  /// diurutkan dari yang paling dekat. [radiusKm] default 25 km.
  Future<List<HotelModel>> getNearbyHotels({
    required double lat,
    required double lng,
    double radiusKm = 25,
    int limit = 20,
  }) async {
    try {
      final res = await ApiClient.get('/hotels/nearby', params: {
        'lat': lat,
        'lng': lng,
        'radius': radiusKm,
        'limit': limit,
      });
      final List data = res.data['data'];
      return data.map((e) => HotelModel.fromJson(e)).toList();
    } on DioException {
      return [];
    }
  }
}
