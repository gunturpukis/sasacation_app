import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../model/explore_model.dart';

class ExploreRepository {
  // Ambil semua item wisata, bisa difilter per kategori
  // category: hotels | beaches | islands | adventure | culture | culinary
  Future<List<ExploreItemModel>> getExplore({String? category, String? search}) async {
    try {
      final res = await ApiClient.get('/explore', params: {
        'category': ?category,
        'search': ?search,
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
        'notes': ?notes,
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

  /// F11: jadwalkan ulang booking confirmed. Kembalikan selisih harga
  /// (price_diff > 0 = perlu bayar tambahan, belum otomatis).
  Future<Map<String, dynamic>> rescheduleBooking({
    required String id,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      final res = await ApiClient.patch('/bookings/$id/reschedule', data: {
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
      });
      final data = res.data['data'] as Map<String, dynamic>? ?? {};
      double numVal(String key) {
        final v = data[key];
        if (v is num) return v.toDouble();
        return double.tryParse('$v') ?? 0;
      }

      return {
        'success': true,
        'message': res.data['message'] ?? 'Jadwal booking diperbarui',
        'priceDiff': numVal('price_diff'),
        'newTotal': numVal('new_total'),
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal menjadwalkan ulang',
      };
    }
  }

  /// S1.3: info resume penuh (termasuk `expiresAt` untuk countdown).
  /// 404 = tidak ada pembayaran aktif (null, bukan error).
  Future<Map<String, dynamic>?> getResumeInfo(String bookingId) async {
    try {
      final res = await ApiClient.get('/checkout/resume/$bookingId');
      return Map<String, dynamic>.from(res.data['data'] as Map);
    } catch (_) {
      return null;
    }
  }

  /// Lanjutkan pembayaran booking pending (F1): ambil Snap `redirectUrl`
  /// yang masih aktif. 404 = tidak ada pembayaran aktif → panggil
  /// `/checkout/pay` ulang (di luar scope fungsi ini).
  Future<Map<String, dynamic>> resumePayment(String bookingId) async {
    try {
      final res = await ApiClient.get('/checkout/resume/$bookingId');
      final data = res.data['data'] as Map<String, dynamic>;
      return {'success': true, 'redirectUrl': data['redirectUrl'] as String};
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      return {
        'success': false,
        'message': code == 404
            ? 'Tidak ada pembayaran aktif untuk booking ini'
            : e.response?.data?['message'] ?? 'Gagal melanjutkan pembayaran',
      };
    }
  }
}
