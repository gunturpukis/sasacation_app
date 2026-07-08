part of 'hotel_bloc.dart';

abstract class HotelState {}

class HotelInitial extends HotelState {}

class HotelLoading extends HotelState {}

// FIX: pisahkan state featured dan detail agar tidak saling override
class HotelFeaturedLoaded extends HotelState {
  final List<HotelModel> hotels;
  HotelFeaturedLoaded({required this.hotels});
}

class HotelListLoaded extends HotelState {
  final List<HotelModel> hotels;
  HotelListLoaded({required this.hotels});
}

class HotelDetailLoaded extends HotelState {
  final HotelModel hotel;
  HotelDetailLoaded({required this.hotel});
}

// FIX: state yang hold kedua data sekaligus (featured + detail)
class HotelCompositeState extends HotelState {
  final List<HotelModel>? featuredHotels;
  final HotelModel? detailHotel;
  final bool isLoadingFeatured;
  final bool isLoadingDetail;
  final String? featuredError;
  final String? detailError;
  // Fitur geolocation: hotel terdekat dari lokasi user
  final List<HotelModel>? nearbyHotels;
  final bool isLoadingNearby;
  final String? nearbyError;

  HotelCompositeState({
    this.featuredHotels,
    this.detailHotel,
    this.isLoadingFeatured = false,
    this.isLoadingDetail = false,
    this.featuredError,
    this.detailError,
    this.nearbyHotels,
    this.isLoadingNearby = false,
    this.nearbyError,
  });

  HotelCompositeState copyWith({
    List<HotelModel>? featuredHotels,
    HotelModel? detailHotel,
    bool? isLoadingFeatured,
    bool? isLoadingDetail,
    String? featuredError,
    String? detailError,
    List<HotelModel>? nearbyHotels,
    bool? isLoadingNearby,
    String? nearbyError,
  }) =>
      HotelCompositeState(
        featuredHotels: featuredHotels ?? this.featuredHotels,
        detailHotel: detailHotel ?? this.detailHotel,
        isLoadingFeatured: isLoadingFeatured ?? this.isLoadingFeatured,
        isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
        featuredError: featuredError ?? this.featuredError,
        detailError: detailError ?? this.detailError,
        nearbyHotels: nearbyHotels ?? this.nearbyHotels,
        isLoadingNearby: isLoadingNearby ?? this.isLoadingNearby,
        nearbyError: nearbyError ?? this.nearbyError,
      );
}

class HotelError extends HotelState {
  final String message;
  HotelError({required this.message});
}
