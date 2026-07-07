import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../model/checkout_model.dart';

class CheckoutRepository {
  // Initiate checkout session — hitung harga, belum simpan ke DB
  Future<Map<String, dynamic>> initiateCheckout({
    required String hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestCount,
    String? notes,
  }) async {
    try {
      final res = await ApiClient.post('/checkout/initiate', data: {
        'hotelId': hotelId,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'guestCount': guestCount,
        if (notes != null) 'notes': notes,
      });
      return {
        'success': true,
        'session': CheckoutSession.fromJson(res.data['data']),
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal memulai checkout',
      };
    }
  }

  /// Proses pembayaran.
  ///
  /// FIX: Backend versi PostgreSQL (`/api/checkout/pay`) TIDAK memakai
  /// session lookup seperti versi lama — dia butuh detail booking lengkap
  /// dikirim ULANG di body (hotelId, checkIn, checkOut, guestCount, notes,
  /// totalAmount), karena sesi checkout tidak disimpan di server (stateless).
  ///
  /// Sebelumnya method ini hanya mengirim `sessionId` + `paymentMethod`,
  /// yang menyebabkan backend menolak dengan "Data pembayaran tidak lengkap"
  /// karena field wajib (hotelId, checkIn, dll) tidak pernah sampai ke server.
  Future<Map<String, dynamic>> processPayment({
    required String hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int nights,
    required int guestCount,
    required String notes,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    try {
      final res = await ApiClient.post('/checkout/pay', data: {
        'hotelId': hotelId,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'nights': nights,
        'guestCount': guestCount,
        'notes': notes,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
      });
      return {
        'success': true,
        'result': PaymentResult.fromJson(res.data['data']),
        'message': res.data['message'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Pembayaran gagal',
      };
    }
  }

  // Get available payment methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final res = await ApiClient.get('/checkout/methods');
      return (res.data['data'] as List).map((m) => PaymentMethod.fromJson(m)).toList();
    } catch (_) {
      return [];
    }
  }
}
