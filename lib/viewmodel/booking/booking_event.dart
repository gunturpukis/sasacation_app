part of 'booking_bloc.dart';

abstract class BookingEvent {}

class BookingListRequested extends BookingEvent {}

// NOTE: BookingCreateRequested dihapus — gunakan CheckoutBloc untuk membuat booking
// agar semua booking melewati payment flow

class BookingCancelRequested extends BookingEvent {
  final String bookingId;
  BookingCancelRequested({required this.bookingId});
}
