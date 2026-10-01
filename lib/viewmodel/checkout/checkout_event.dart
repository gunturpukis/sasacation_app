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

/// F4: toggle "simpan kartu" — hanya relevan bila metode = credit_card.
class CheckoutSaveCardChanged extends CheckoutEvent {
  final bool save;
  CheckoutSaveCardChanged({required this.save});
}

class CheckoutPaymentConfirmed extends CheckoutEvent {}

class CheckoutReset extends CheckoutEvent {}
