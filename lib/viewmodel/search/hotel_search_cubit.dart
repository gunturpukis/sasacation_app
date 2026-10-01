import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/data/repo/hotel_repository.dart';

enum HotelSortOption { recommended, priceLowHigh, priceHighLow, ratingHigh, newest }

/// F3: dipetakan ke param `sort` server (rating|price_asc|price_desc|newest).
/// `recommended` = tanpa param (urutan backend default).
extension HotelSortOptionApi on HotelSortOption {
  String? get apiValue => switch (this) {
        HotelSortOption.priceLowHigh => 'price_asc',
        HotelSortOption.priceHighLow => 'price_desc',
        HotelSortOption.ratingHigh => 'rating',
        HotelSortOption.newest => 'newest',
        HotelSortOption.recommended => null,
      };
}

class HotelSearchState {
  final bool isLoading;
  final List<HotelModel> allResults;
  final String? query;
  final double? minPrice;
  final double? maxPrice;
  final double minRating;
  final HotelSortOption sort;
  final List<String> amenities;
  final String? error;

  const HotelSearchState({
    this.isLoading = false,
    this.allResults = const [],
    this.query,
    this.minPrice,
    this.maxPrice,
    this.minRating = 0,
    this.sort = HotelSortOption.recommended,
    this.amenities = const [],
    this.error,
  });

  /// Hasil setelah filter rating client diterapkan. Sort & amenities sudah
  /// diurutkan/difilter di server; pengurutan ulang client di bawah
  /// idempoten untuk kunci yang sama (newest mengikuti urutan server).
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
      case HotelSortOption.newest:
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
    List<String>? amenities,
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
        amenities: amenities ?? this.amenities,
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
    List<String>? amenities,
  }) async {
    emit(state._copy(
      isLoading: true,
      query: query,
      minPrice: minPrice,
      maxPrice: maxPrice,
      amenities: amenities,
      clearError: true,
    ));
    final hotels = await _repo.getHotels(
      search: query,
      minPrice: minPrice,
      maxPrice: maxPrice,
      amenities: amenities ?? state.amenities,
      sort: state.sort.apiValue,
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

  void setSort(HotelSortOption sort) {
    emit(state._copy(sort: sort));
    search(
      query: state.query,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      amenities: state.amenities,
    );
  }

  void setAmenities(List<String> amenities) {
    search(
      query: state.query,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      amenities: amenities,
    );
  }

  void applyPriceRange(double? minPrice, double? maxPrice) {
    search(query: state.query, minPrice: minPrice, maxPrice: maxPrice);
  }
}
