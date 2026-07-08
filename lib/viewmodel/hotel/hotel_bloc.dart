import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/data/repo/hotel_repository.dart';

part 'hotel_event.dart';
part 'hotel_state.dart';

/// HotelBloc — ViewModel untuk hotels
/// FIX: menggunakan HotelCompositeState agar featured dan detail tidak
/// saling override saat user navigate hotel detail → back → home
class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final HotelRepository _hotelRepository;

  HotelBloc({HotelRepository? hotelRepository})
      : _hotelRepository = hotelRepository ?? HotelRepository(),
        super(HotelCompositeState()) {
    on<HotelFeaturedRequested>(_onFeaturedRequested);
    on<HotelListRequested>(_onListRequested);
    on<HotelDetailRequested>(_onDetailRequested);
    on<HotelNearbyRequested>(_onNearbyRequested);
  }

  Future<void> _onFeaturedRequested(
      HotelFeaturedRequested event, Emitter<HotelState> emit) async {
    final current = state is HotelCompositeState
        ? state as HotelCompositeState
        : HotelCompositeState();

    // Jika sudah ada data featured, tidak perlu fetch ulang
    if (current.featuredHotels != null && current.featuredHotels!.isNotEmpty) return;

    emit(current.copyWith(isLoadingFeatured: true));
    final hotels = await _hotelRepository.getFeaturedHotels();
    final updated = state is HotelCompositeState
        ? state as HotelCompositeState
        : HotelCompositeState();
    emit(updated.copyWith(
      isLoadingFeatured: false,
      featuredHotels: hotels,
      featuredError: hotels.isEmpty ? 'Tidak ada hotel featured' : null,
    ));
  }

  Future<void> _onListRequested(
      HotelListRequested event, Emitter<HotelState> emit) async {
    emit(HotelLoading());
    final hotels = await _hotelRepository.getHotels(
      search: event.search,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
    );
    emit(HotelListLoaded(hotels: hotels));
  }

  Future<void> _onDetailRequested(
      HotelDetailRequested event, Emitter<HotelState> emit) async {
    final current = state is HotelCompositeState
        ? state as HotelCompositeState
        : HotelCompositeState();

    emit(current.copyWith(isLoadingDetail: true, detailHotel: null));
    final hotel = await _hotelRepository.getHotelById(event.hotelId);
    final updated = state is HotelCompositeState
        ? state as HotelCompositeState
        : HotelCompositeState();
    emit(updated.copyWith(
      isLoadingDetail: false,
      detailHotel: hotel,
      detailError: hotel == null ? 'Hotel tidak ditemukan' : null,
    ));
  }

  Future<void> _onNearbyRequested(
      HotelNearbyRequested event, Emitter<HotelState> emit) async {
    final current = state is HotelCompositeState
        ? state as HotelCompositeState
        : HotelCompositeState();

    emit(current.copyWith(isLoadingNearby: true, nearbyError: null));
    final hotels = await _hotelRepository.getNearbyHotels(
      lat: event.latitude,
      lng: event.longitude,
      radiusKm: event.radiusKm,
    );
    final updated = state is HotelCompositeState
        ? state as HotelCompositeState
        : HotelCompositeState();
    emit(updated.copyWith(
      isLoadingNearby: false,
      nearbyHotels: hotels,
      nearbyError: hotels.isEmpty ? 'Tidak ada hotel di sekitar lokasi Anda' : null,
    ));
  }
}
