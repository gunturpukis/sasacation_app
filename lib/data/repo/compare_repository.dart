import 'package:sasacation/data/api/api_client.dart';

/// F.3: repository untuk POST /ai/compare.
/// Request: {hotelIds: [2..3]} → {matrix[], verdict, tradeoffs[]}
class CompareRepository {
  Future<Map<String, dynamic>> compare(List<String> hotelIds) async {
    final res = await ApiClient.post(
      '/ai/compare',
      data: {'hotelIds': hotelIds},
      timeout: const Duration(seconds: 120),
    );
    final data = res.data['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Respons compare tidak valid');
  }
}
