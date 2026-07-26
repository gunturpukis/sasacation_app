
import '../api/api_client.dart';
import '../model/payment_model.dart';
 
/// Repository: PaymentRepository
/// Riwayat pembayaran REAL — pengganti jujur dari konsep "Travel Wallet"
/// di mockup yang datanya fiktif (lihat catatan di payment_history_screen.dart).
class PaymentRepository {
  Future<Map<String, dynamic>> getPaymentHistory() async {
    final res = await ApiClient.get('/payments');
    final list = (res.data['data'] as List)
        .map((p) => PaymentModel.fromJson(p as Map<String, dynamic>))
        .toList();
    return {
      'payments': list,
      'totalSpent': double.parse((res.data['totalSpent'] ?? 0).toString()),
    };
  }
}
 