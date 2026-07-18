import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../api/api_client.dart';
import '../model/user_model.dart';

class AuthRepository {
  static final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  static final _firebaseAuth = fb.FirebaseAuth.instance;

  // ── Email/Password (via Firebase Auth) ──────────────────────────────────
  Future<Map<String, dynamic>> register({required String name, required String email, required String password}) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.updateDisplayName(name);
      return _exchangeFirebaseToken(cred.user);
    } on fb.FirebaseAuthException catch (e) {
      return {'success': false, 'message': _firebaseMsg(e)};
    }
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return _exchangeFirebaseToken(cred.user);
    } on fb.FirebaseAuthException catch (e) {
      return {'success': false, 'message': _firebaseMsg(e)};
    }
  }

  // ── Google Sign In (via Firebase Auth) ───────────────────────────────────
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return {'success': false, 'message': 'Login Google dibatalkan'};

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _firebaseAuth.signInWithCredential(credential);
      return _exchangeFirebaseToken(cred.user);
    } on fb.FirebaseAuthException catch (e) {
      return {'success': false, 'message': _firebaseMsg(e)};
    } catch (e) {
      return {'success': false, 'message': 'Google Sign In gagal'};
    }
  }

  // ── Apple Sign In (via Firebase Auth) ────────────────────────────────────
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      final appleCred = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = fb.OAuthProvider('apple.com').credential(
        idToken: appleCred.identityToken,
        accessToken: appleCred.authorizationCode,
      );
      final cred = await _firebaseAuth.signInWithCredential(oauthCredential);

      // Nama lengkap dari Apple hanya dikirim SEKALI saat otorisasi pertama,
      // Firebase user object tidak otomatis mengisi displayName untuk Apple.
      final name = [appleCred.givenName, appleCred.familyName].where((s) => s?.isNotEmpty == true).join(' ');
      if (name.isNotEmpty && cred.user?.displayName == null) {
        await cred.user?.updateDisplayName(name);
      }

      return _exchangeFirebaseToken(cred.user);
    } on fb.FirebaseAuthException catch (e) {
      return {'success': false, 'message': _firebaseMsg(e)};
    } catch (e) {
      if (e.toString().contains('canceled')) return {'success': false, 'message': 'Login Apple dibatalkan'};
      return {'success': false, 'message': 'Apple Sign In gagal'};
    }
  }

  /// Tukar Firebase idToken dengan sesi backend Sasacation (JWT sendiri).
  /// Backend memverifikasi idToken ini via Firebase Admin SDK di endpoint
  /// POST /auth/firebase — jadi identitas user (email, uid) tidak bisa
  /// dipalsukan oleh client.
  Future<Map<String, dynamic>> _exchangeFirebaseToken(fb.User? user) async {
    if (user == null) return {'success': false, 'message': 'Login Firebase gagal'};
    try {
      final idToken = await user.getIdToken();
      final res = await ApiClient.post('/auth/firebase', data: {'idToken': idToken});
      await _saveSession(res.data['data']['token'], res.data['data']['user']);
      return {'success': true, 'user': UserModel.fromJson(res.data['data']['user'])};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Gagal menghubungi server'};
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
        'name': ?name,
        'avatar': ?avatar,
      });
      return {'success': true, 'user': UserModel.fromJson(res.data['data']['user'])};
    } on DioException catch (e) {
      return {'success': false, 'message': _msg(e)};
    }
  }

  /// Kirim lokasi GPS terakhir user ke backend (fitur geolocation "hotel terdekat").
  Future<bool> updateLocation({required double latitude, required double longitude}) async {
    try {
      await ApiClient.patch('/auth/location', data: {'latitude': latitude, 'longitude': longitude});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut().catchError((_) {});
    await _firebaseAuth.signOut().catchError((_) {});
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

  String _firebaseMsg(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
      default:
        return e.message ?? 'Autentikasi gagal';
    }
  }
}
