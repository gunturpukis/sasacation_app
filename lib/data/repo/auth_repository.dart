import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../api/api_client.dart';
import '../model/user_model.dart';

class AuthRepository {
  static final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Email login
  Future<Map<String, dynamic>> register({required String name, required String email, required String password}) async {
    try {
      final res = await ApiClient.post('/auth/register', data: {'name': name, 'email': email, 'password': password});
      await _saveSession(res.data['data']['token'], res.data['data']['user']);
      return {'success': true, 'user': UserModel.fromJson(res.data['data']['user'])};
    } on DioException catch (e) {
      return {'success': false, 'message': _msg(e)};
    }
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final res = await ApiClient.post('/auth/login', data: {'email': email, 'password': password});
      await _saveSession(res.data['data']['token'], res.data['data']['user']);
      return {'success': true, 'user': UserModel.fromJson(res.data['data']['user'])};
    } on DioException catch (e) {
      return {'success': false, 'message': _msg(e)};
    }
  }

  // Google Sign In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return {'success': false, 'message': 'Login Google dibatalkan'};
      final res = await ApiClient.post('/auth/social', data: {
        'provider': 'google',
        'providerId': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? googleUser.email,
        'avatar': googleUser.photoUrl,
      });
      await _saveSession(res.data['data']['token'], res.data['data']['user']);
      return {'success': true, 'user': UserModel.fromJson(res.data['data']['user'])};
    } on DioException catch (e) {
      return {'success': false, 'message': _msg(e)};
    } catch (e) {
      return {'success': false, 'message': 'Google Sign In gagal'};
    }
  }

  // Apple Sign In
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      final cred = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final name = [cred.givenName, cred.familyName].where((s) => s?.isNotEmpty == true).join(' ');
      final res = await ApiClient.post('/auth/social', data: {
        'provider': 'apple',
        'providerId': cred.userIdentifier ?? '',
        'email': cred.email ?? '${cred.userIdentifier}@privaterelay.appleid.com',
        'name': name.isNotEmpty ? name : 'Apple User',
      });
      await _saveSession(res.data['data']['token'], res.data['data']['user']);
      return {'success': true, 'user': UserModel.fromJson(res.data['data']['user'])};
    } on DioException catch (e) {
      return {'success': false, 'message': _msg(e)};
    } catch (e) {
      if (e.toString().contains('canceled')) return {'success': false, 'message': 'Login Apple dibatalkan'};
      return {'success': false, 'message': 'Apple Sign In gagal'};
    }
  }

  Future<UserModel?> getProfile() async {
    try {
      final res = await ApiClient.get('/auth/me');
      return UserModel.fromJson(res.data['data']['user']);
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>> updateProfile({String? name, String? avatar}) async {
    try {
      final res = await ApiClient.put('/auth/profile', data: {
        if (name != null) 'name': name,
        if (avatar != null) 'avatar': avatar,
      });
      return {'success': true, 'user': UserModel.fromJson(res.data['data']['user'])};
    } on DioException catch (e) {
      return {'success': false, 'message': _msg(e)};
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut().catchError((_) {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.setBool('is_logged_in', false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<void> _saveSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', user['id']);
    await prefs.setBool('is_logged_in', true);
  }

  String _msg(DioException e) => e.response?.data?['message'] ?? 'Terjadi kesalahan jaringan';
}
