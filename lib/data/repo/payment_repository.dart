
import 'package:dio/dio.dart';

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

/// F9: kartu Travel Pass loyalitas (tanpa nomor kartu palsu — pass_id
/// sebagai ID member) + transfer saldo antar user.
class LoyaltyInfo {
  final String passId;
  final int points;
  final String tier;
  final int tripsCompleted;
  final String? memberSince;

  const LoyaltyInfo({
    required this.passId,
    required this.points,
    required this.tier,
    required this.tripsCompleted,
    this.memberSince,
  });

  factory LoyaltyInfo.fromJson(Map<String, dynamic> json) {
    int intVal(dynamic v) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    return LoyaltyInfo(
      passId: (json['pass_id'] ?? '').toString(),
      points: intVal(json['points']),
      tier: (json['tier'] ?? 'Bronze').toString(),
      tripsCompleted: intVal(json['trips_completed']),
      memberSince: json['member_since']?.toString(),
    );
  }
}

class WalletRepository {
  Future<LoyaltyInfo?> getLoyalty() async {
    try {
      final res = await ApiClient.get('/loyalty');
      final raw = res.data['data'];
      if (raw is! Map) return null;
      return LoyaltyInfo.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> transfer({
    required String email,
    required double amount,
    String? note,
  }) async {
    try {
      await ApiClient.post('/wallet/transfer', data: {
        'email': email,
        'amount': amount,
        if (note != null && note.isNotEmpty) 'note': note,
      });
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Transfer gagal',
      };
    }
  }
}
 