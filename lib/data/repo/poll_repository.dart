import 'package:dio/dio.dart';
import 'package:sasacation/data/api/api_client.dart';
import 'package:sasacation/data/model/poll_model.dart';

/// F7: repository voting grup.
class PollRepository {
  PollModel? _parse(dynamic raw) {
    if (raw is! Map) return null;
    try {
      return PollModel.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<List<PollModel>> getOpenPolls() async {
    try {
      final res = await ApiClient.get('/polls/open');
      final raw = res.data['data'];
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((e) => _parse(e))
          .whereType<PollModel>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<PollModel?> getPoll(String id) async {
    try {
      final res = await ApiClient.get('/polls/$id');
      return _parse(res.data['data']);
    } catch (_) {
      return null;
    }
  }

  /// Vote (pindah pilihan = ganti). Kembalikan poll terbaru untuk render
  /// ulang, atau pesan error.
  Future<Map<String, dynamic>> vote({
    required String pollId,
    required String optionId,
  }) async {
    try {
      final res = await ApiClient.post('/polls/$pollId/vote',
          data: {'optionId': optionId});
      final poll = _parse(res.data['data']);
      if (poll == null) return {'success': false, 'message': 'Respons tak dikenal'};
      return {'success': true, 'poll': poll};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal memberikan suara',
      };
    }
  }
}
