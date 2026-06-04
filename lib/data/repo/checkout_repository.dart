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

  // Process payment
  Future<Map<String, dynamic>> processPayment({
    required String sessionId,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final res = await ApiClient.post('/checkout/pay', data: {
        'sessionId': sessionId,
        'paymentMethod': paymentMethod,
        if (paymentDetails != null) 'paymentDetails': paymentDetails,
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
      return (res.data['data'] as List)
          .map((m) => PaymentMethod.fromJson(m))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
