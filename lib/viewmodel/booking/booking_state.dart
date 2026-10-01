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

/// F1: redirectUrl Snap aktif siap dibuka (layar memanggil url_launcher).
class BookingResumeReady extends BookingState {
  final String bookingId;
  final String redirectUrl;
  BookingResumeReady({required this.bookingId, required this.redirectUrl});
}
