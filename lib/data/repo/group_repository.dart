import 'package:dio/dio.dart';
import 'package:sasacation/data/api/api_client.dart';
import 'package:sasacation/data/model/group_model.dart';

/// F8: repository budget grup.
class GroupRepository {
  GroupModel? _parse(dynamic raw) {
    if (raw is! Map) return null;
    try {
      return GroupModel.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<List<GroupModel>> getMyGroups() async {
    try {
      final res = await ApiClient.get('/groups/my');
      final raw = res.data['data'];
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((e) => _parse(e))
          .whereType<GroupModel>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<GroupModel?> getGroup(String id) async {
    try {
      final res = await ApiClient.get('/groups/$id');
      return _parse(res.data['data']);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createGroup({
    required String name,
    String? destination,
    double? budgetTotal,
  }) async {
    try {
      final res = await ApiClient.post('/groups', data: {
        'name': name,
        if (destination != null && destination.isNotEmpty)
          'destination': destination,
        if (budgetTotal != null) 'budget_total': budgetTotal,
      });
      final group = _parse(res.data['data']);
      if (group == null) {
        return {'success': false, 'message': 'Respons tak dikenal'};
      }
      return {'success': true, 'group': group};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal membuat grup',
      };
    }
  }

  Future<Map<String, dynamic>> addExpense({
    required String groupId,
    required String label,
    required double amount,
    String? category,
  }) async {
    try {
      await ApiClient.post('/groups/$groupId/expenses', data: {
        'label': label,
        'amount': amount,
        if (category != null && category.isNotEmpty)
          'category': category,
      });
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal menambah pengeluaran',
      };
    }
  }

  Future<Map<String, dynamic>> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    try {
      await ApiClient.delete('/groups/$groupId/expenses/$expenseId');
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal menghapus pengeluaran',
      };
    }
  }
}
