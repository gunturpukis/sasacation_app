import 'package:sasacation/data/api/api_client.dart';

/// F.4: repository profil travel.
/// - GET /preferences (auth) → row snake_case + budgetTier turunan
/// - GET /preferences/profile (auth) → agregat + alias camelCase + stats
/// - PUT /preferences (auth) → body camelCase (budgetTier, tripTypes, ...)
class PreferencesRepository {
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final res = await ApiClient.get('/preferences/profile');
      final data = res.data['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } catch (_) {
      return null; // fail-soft: profil kosong = tampilkan quiz
    }
  }

  Future<bool> savePreferences(Map<String, dynamic> body) async {
    try {
      final res = await ApiClient.put('/preferences', data: body);
      return res.data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}
