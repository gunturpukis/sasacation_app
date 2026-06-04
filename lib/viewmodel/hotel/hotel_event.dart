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
