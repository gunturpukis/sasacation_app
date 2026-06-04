import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../model/explore_model.dart';

class ExploreRepository {
  // Ambil semua item wisata, bisa difilter per kategori
  // category: hotels | beaches | islands | adventure | culture | culinary
  Future<List<ExploreItemModel>> getExplore({String? category, String? search}) async {
    try {
      final res = await ApiClient.get('/explore', params: {
        if (category != null) 'category': category,
        if (search != null) 'search': search,
      });
      final List data = res.data['data'];
      return data.map((e) => ExploreItemModel.fromJson(e)).toList();
    } on DioException {
      return [];
    }
  }

  // Ambil semua kategori
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final res = await ApiClient.get('/explore/categories');
      return List<Map<String, dynamic>>.from(res.data['data']);
    } catch (_) {
      return [];
    }
  }
}

class BookingRepository {
  // Buat booking baru
  Future<Map<String, dynamic>> createBooking({
    required String hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestCount,
    String? notes,
  }) async {
    try {
      final res = await ApiClient.post('/bookings', data: {
        'hotelId': hotelId,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'guestCount': guestCount,
        if (notes != null) 'notes': notes,
      });
      return {
        'success': true,
        'booking': BookingModel.fromJson(res.data['data']),
        'message': res.data['message'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal membuat booking',
      };
    }
  }

  // Ambil booking milik user yang sedang login
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final res = await ApiClient.get('/bookings/my');
      final List data = res.data['data'];
      return data.map((e) => BookingModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // Detail booking
  Future<BookingModel?> getBookingById(String id) async {
    try {
      final res = await ApiClient.get('/bookings/$id');
      return BookingModel.fromJson(res.data['data']);
    } catch (_) {
      return null;
    }
  }

  // Batalkan booking
  Future<Map<String, dynamic>> cancelBooking(String id) async {
    try {
      final res = await ApiClient.patch('/bookings/$id/cancel');
      return {'success': true, 'message': res.data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal membatalkan booking',
      };
    }
  }
}
