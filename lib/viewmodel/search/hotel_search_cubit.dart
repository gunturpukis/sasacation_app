import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/data/repo/hotel_repository.dart';

enum HotelSortOption { recommended, priceLowHigh, priceHighLow, ratingHigh }

class HotelSearchState {
  final bool isLoading;
  final List<HotelModel> allResults;
  final String? query;
  final double? minPrice;
  final double? maxPrice;
  final double minRating;
  final HotelSortOption sort;
  final String? error;

  const HotelSearchState({
    this.isLoading = false,
    this.allResults = const [],
    this.query,
    this.minPrice,
    this.maxPrice,
    this.minRating = 0,
    this.sort = HotelSortOption.recommended,
    this.error,
  });

  /// Hasil setelah filter rating & sort diterapkan di sisi client.
  /// Filter harga & pencarian teks sudah dilakukan di server (via repository).
  List<HotelModel> get results {
    final list = allResults.where((h) => h.rating >= minRating).toList();
    switch (sort) {
      case HotelSortOption.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case HotelSortOption.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case HotelSortOption.ratingHigh:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case HotelSortOption.recommended:
        break;
    }
    return list;
  }

  HotelSearchState _copy({
    bool? isLoading,
    List<HotelModel>? allResults,
    String? query,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    HotelSortOption? sort,
    String? error,
    bool clearError = false,
  }) =>
      HotelSearchState(
        isLoading: isLoading ?? this.isLoading,
        allResults: allResults ?? this.allResults,
        query: query ?? this.query,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        minRating: minRating ?? this.minRating,
        sort: sort ?? this.sort,
        error: clearError ? null : (error ?? this.error),
      );
}

/// ViewModel: HotelSearchCubit
/// Dipisah dari HotelBloc secara sengaja: HotelBloc dipakai bersama untuk
/// featured hotels & hotel detail lewat HotelCompositeState, jadi kalau layar
/// search memakai bloc yang sama, event pencarian akan menimpa state itu dan
/// merusak tampilan Home saat kembali. Cubit ini berdiri sendiri per halaman.
class HotelSearchCubit extends Cubit<HotelSearchState> {
  final HotelRepository _repo;

  HotelSearchCubit({HotelRepository? repo})
      : _repo = repo ?? HotelRepository(),
        super(const HotelSearchState());

  Future<void> search({
    String? query,
    double? minPrice,
    double? maxPrice,
  }) async {
    emit(state._copy(
      isLoading: true,
      query: query,
      minPrice: minPrice,
      maxPrice: maxPrice,
      clearError: true,
    ));
    final hotels = await _repo.getHotels(
      search: query,
      minPrice: minPrice,
      maxPrice: maxPrice,
      limit: 30,
    );
    emit(state._copy(
      isLoading: false,
      allResults: hotels,
      error: hotels.isEmpty ? 'Tidak ada hotel ditemukan untuk pencarian ini' : null,
      clearError: hotels.isNotEmpty,
    ));
  }

  void setMinRating(double rating) => emit(state._copy(minRating: rating));

  void setSort(HotelSortOption sort) => emit(state._copy(sort: sort));

  void applyPriceRange(double? minPrice, double? maxPrice) {
    search(query: state.query, minPrice: minPrice, maxPrice: maxPrice);
  }
}
