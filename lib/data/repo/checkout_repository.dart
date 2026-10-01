import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../model/checkout_model.dart';

class CheckoutRepository {
  // Initiate checkout session
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
        'notes': ?notes,
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

  // Process payment
  // FIX: sebelumnya kirim `sessionId` yang TIDAK PERNAH dipakai backend
  // (backend stateless, tidak pernah menyimpan session dari /initiate) —
  // sekarang kirim data booking langsung sesuai yang backend butuhkan.
  // Response juga berubah: bukan lagi hasil pembayaran final, tapi info
  // untuk membuka halaman Midtrans Snap (snapToken/redirectUrl).
  Future<Map<String, dynamic>> processPayment({
    required String hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestCount,
    String? notes,
    required String paymentMethod,
    // F4: khusus credit_card — memunculkan toggle save di Snap agar kartu
    // tercatat ke GET /payment-methods untuk pemakaian berikutnya.
    bool saveCard = false,
  }) async {
    try {
      final res = await ApiClient.post('/checkout/pay', data: {
        'hotelId': hotelId,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'guestCount': guestCount,
        'notes': ?notes,
        'paymentMethod': paymentMethod,
        if (saveCard) 'saveCard': true,
      });
      return {
        'success': true,
        'initiated': CheckoutPaymentInitiated.fromJson(res.data['data']),
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Pembayaran gagal',
      };
    }
  }

  // Polling status pembayaran setelah user membuka halaman Snap — status
  // sebenarnya di-update async lewat webhook Midtrans, jadi app perlu
  // tanya-tanya berkala sampai final ('success'/'failed').
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    try {
      final res = await ApiClient.get('/checkout/status/$transactionId');
      final data = res.data['data'];
      final status = data['payment']['status'] as String;
      return {
        'success': true,
        'status': status, // 'pending' | 'success' | 'failed' | 'refunded'
        'result': status == 'success' ? PaymentResult.fromJson(data) : null,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal mengecek status pembayaran',
      };
    }
  }

  // Get available payment methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final res = await ApiClient.get('/checkout/methods');
      return (res.data['data'] as List)
          .map((m) => PaymentMethod.fromJson(m))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// F4: kartu tersimpan milik user (bisa kosong — belum pernah save).
  Future<List<SavedPaymentMethod>> getSavedMethods() async {
    try {
      final res = await ApiClient.get('/payment-methods');
      final raw = res.data['data'];
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(SavedPaymentMethod.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// F4: ganti julukan kartu ("Business"). Backend 500 untuk id tak dikenal
  /// (seharusnya 404) — pesan error generik sudah cukup di UI.
  Future<Map<String, dynamic>> renameSavedMethod({
    required String id,
    required String label,
  }) async {
    try {
      await ApiClient.patch('/payment-methods/$id', data: {'label': label});
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal mengganti nama kartu',
      };
    }
  }
}
