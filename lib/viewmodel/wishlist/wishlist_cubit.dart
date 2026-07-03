import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel: WishlistCubit
/// Menyimpan daftar id hotel yang disimpan user secara lokal (SharedPreferences).
/// Dibuat sebagai Cubit terpisah dari HotelBloc supaya tidak mengganggu
/// HotelCompositeState yang sudah dipakai bersama oleh FeaturedHotels & HotelDetail.
class WishlistCubit extends Cubit<Set<String>> {
  static const _prefsKey = 'wishlist_hotel_ids';

  WishlistCubit() : super(const {}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? [];
    emit(saved.toSet());
  }

  bool isSaved(String hotelId) => state.contains(hotelId);

  Future<void> toggle(String hotelId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(hotelId)) {
      updated.remove(hotelId);
    } else {
      updated.add(hotelId);
    }
    emit(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, updated.toList());
  }
}
