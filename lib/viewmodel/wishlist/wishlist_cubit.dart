import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sasacation/data/repo/wishlist_repository.dart';

/// ViewModel: WishlistCubit
///
/// PERUBAHAN dari versi sebelumnya:
/// SEBELUM - wishlist hanya disimpan di SharedPreferences (lokal per-device).
///           Backend/AI tidak pernah tahu apa yang di-wishlist user, sehingga
///           personalisasi ("harga hotel wishlist-mu turun") tidak mungkin dibuat.
/// SEKARANG - wishlist disinkronkan ke server. SharedPreferences tetap dipakai
///           sebagai cache offline (biar UI tetap responsif tanpa nunggu network)
///           dan sebagai fallback untuk guest/belum login.
///
/// State tetap Set<String> (hotel id) supaya semua widget yang sudah pakai
/// `context.read<WishlistCubit>().isSaved(id)` tidak perlu berubah sama sekali.
class WishlistCubit extends Cubit<Set<String>> {
  static const _cacheKey = 'wishlist_hotel_ids_cache';

  final WishlistRepository _repo;

  WishlistCubit({WishlistRepository? repository})
      : _repo = repository ?? WishlistRepository(),
        super(const {}) {
    _load();
  }

  Future<bool> _isLoggedIn(SharedPreferences prefs) async =>
      prefs.getString('auth_token') != null;

  Future<void> _load() async {
    // 1. Tampilkan cache lokal dulu supaya UI langsung terisi (no loading flicker)
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList(_cacheKey) ?? [];
    emit(cached.toSet());

    // 2. Kalau login, sinkronkan dengan server (source of truth)
    if (!await _isLoggedIn(prefs)) return;
    try {
      final serverWishlist = await _repo.getWishlist();
      final ids = serverWishlist.map((h) => h['id'] as String).toSet();
      emit(ids);
      await prefs.setStringList(_cacheKey, ids.toList());
    } catch (_) {
      // Gagal fetch (offline dll) → tetap pakai cache, tidak melempar error ke UI
    }
  }

  bool isSaved(String hotelId) => state.contains(hotelId);

  Future<void> toggle(String hotelId) async {
    // Optimistic update: UI langsung responsif, tidak nunggu roundtrip network
    final updated = Set<String>.from(state);
    final wasSaved = updated.contains(hotelId);
    wasSaved ? updated.remove(hotelId) : updated.add(hotelId);
    emit(updated);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_cacheKey, updated.toList());

    if (!await _isLoggedIn(prefs)) return; // guest: cache lokal saja, tidak ada backend untuk disinkron

    try {
      await _repo.toggle(hotelId);
    } catch (_) {
      // Rollback kalau request gagal, supaya state tidak "bohong"
      final rolledBack = Set<String>.from(state);
      wasSaved ? rolledBack.add(hotelId) : rolledBack.remove(hotelId);
      emit(rolledBack);
      await prefs.setStringList(_cacheKey, rolledBack.toList());
    }
  }
}
