import 'package:dio/dio.dart';
import 'package:sasacation/data/api/api_client.dart';
import 'package:sasacation/data/model/task_model.dart';

/// F10: repository travel tasks.
class TaskRepository {
  Future<List<TaskModel>> getMyTasks({bool? upcoming}) async {
    try {
      final res = await ApiClient.get('/tasks/my', params: {
        if (upcoming != null) 'upcoming': upcoming,
      });
      final raw = res.data['data'];
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((e) {
            try {
              return TaskModel.fromJson(Map<String, dynamic>.from(e));
            } catch (_) {
              return null;
            }
          })
          .whereType<TaskModel>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createTask({
    required String title,
    required String kind,
    String? detail,
  }) async {
    try {
      await ApiClient.post('/tasks', data: {
        'title': title,
        'kind': kind,
        if (detail != null && detail.isNotEmpty) 'detail': detail,
      });
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal membuat task',
      };
    }
  }

  Future<bool> setDone({required String id, required bool done}) async {
    try {
      await ApiClient.patch('/tasks/$id/done', data: {'done': done});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await ApiClient.delete('/tasks/$id');
      return true;
    } catch (_) {
      return false;
    }
  }
}
