part of 'hotel_bloc.dart';

abstract class HotelEvent {}

class HotelFeaturedRequested extends HotelEvent {}

class HotelListRequested extends HotelEvent {
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  HotelListRequested({this.search, this.minPrice, this.maxPrice});
}

class HotelDetailRequested extends HotelEvent {
  final String hotelId;
  HotelDetailRequested({required this.hotelId});
}

/// Minta hotel terdekat dari koordinat GPS user saat ini (fitur geolocation).
/// Koordinat didapat dari LocationService di layer UI sebelum event ini
/// di-dispatch.
class HotelNearbyRequested extends HotelEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;
  HotelNearbyRequested({required this.latitude, required this.longitude, this.radiusKm = 25});
}
