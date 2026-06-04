part of 'checkout_bloc.dart';

abstract class CheckoutEvent {}

class CheckoutInitiated extends CheckoutEvent {
  final String hotelId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final String? notes;

  CheckoutInitiated({
    required this.hotelId,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    this.notes,
  });
}

class CheckoutPaymentMethodSelected extends CheckoutEvent {
  final PaymentMethod method;
  CheckoutPaymentMethodSelected({required this.method});
}

class CheckoutPaymentConfirmed extends CheckoutEvent {}

class CheckoutReset extends CheckoutEvent {}
