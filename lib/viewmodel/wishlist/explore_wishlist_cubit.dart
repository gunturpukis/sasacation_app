import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel: ExploreWishlistCubit — wishlist destinasi & restoran.
///
/// BERBEDA dari [WishlistCubit] (hotel): backend `/wishlist` saat ini hanya
/// mengenal hotelId (lihat `WishlistRepository.toggle`), jadi explore item
/// disimpan LOKAL di SharedPreferences — tanpa klaim sinkronisasi server.
///
/// Alasan pakai cubit (bukan prefs per-widget): key
/// `explore_wishlist_ids_cache` harus terbaca di banyak layar (detail
/// destinasi + tab Saved), supaya hati "tersimpan" tidak pernah
/// menyesatkan — dulu key ini hanya dibaca oleh layar detailnya sendiri.
///
/// State Set<String> (explore id) mengikuti pola [WishlistCubit].
class ExploreWishlistCubit extends Cubit<Set<String>> {
  static const cacheKey = 'explore_wishlist_ids_cache';

  /// Load awal harus selesai sebelum toggle pertama, supaya tap cepat
  /// tidak menimpa hasil read-modify-write yang tertukar.
  late final Future<void> _ready;

  ExploreWishlistCubit() : super(const {}) {
    _ready = _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList(cacheKey) ?? [];
    emit(cached.toSet());
  }

  /// Toggle dan kembalikan status BARU (true = tersimpan). Pemanggil
  /// memakai hasil ini untuk pesan UI, bukan snapshot sebelum toggle —
  /// aman terhadap tap beruntun.
  Future<bool> toggle(String exploreId) async {
    await _ready;
    final updated = Set<String>.from(state);
    final wasSaved = updated.contains(exploreId);
    wasSaved ? updated.remove(exploreId) : updated.add(exploreId);
    emit(updated);

    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setStringList(cacheKey, updated.toList())) {
      // Tulis gagal → kembalikan state lama supaya UI tidak bohong.
      final rolledBack = Set<String>.from(state);
      wasSaved ? rolledBack.add(exploreId) : rolledBack.remove(exploreId);
      emit(rolledBack);
      return wasSaved;
    }
    return !wasSaved;
  }
}
