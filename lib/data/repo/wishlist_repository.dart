import 'package:sasacation/data/api/api_client.dart';

/// Repository: WishlistRepository
/// Sebelumnya wishlist HANYA hidup di SharedPreferences (lokal per-device),
/// sehingga backend/AI tidak pernah tahu apa yang di-wishlist user.
/// Sekarang wishlist disinkronkan ke server supaya bisa dipakai sebagai
/// sinyal personalisasi oleh AI (lihat userContextService di backend).
class WishlistRepository {
  Future<List<Map<String, dynamic>>> getWishlist() async {
    final response = await ApiClient.get('/wishlist');
    final data = response.data['data'] as List;
    return data.cast<Map<String, dynamic>>();
  }

  /// Return true kalau hotel tersimpan setelah toggle, false kalau dihapus
  Future<bool> toggle(String hotelId) async {
    final response = await ApiClient.post('/wishlist/toggle', data: {'hotelId': hotelId});
    return response.data['data']['saved'] as bool;
  }
}
