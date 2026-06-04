part of 'booking_bloc.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingListLoaded extends BookingState {
  final List<BookingModel> bookings;
  BookingListLoaded({required this.bookings});
}

class BookingCancelled extends BookingState {
  final String bookingId;
  BookingCancelled({required this.bookingId});
}

class BookingError extends BookingState {
  final String message;
  BookingError({required this.message});
}
