part of 'checkout_bloc.dart';

abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSessionLoaded extends CheckoutState {
  final CheckoutSession session;
  final PaymentMethod? selectedMethod;

  CheckoutSessionLoaded({required this.session, this.selectedMethod});

  bool get canPay => selectedMethod != null;
}

class CheckoutPaymentProcessing extends CheckoutState {}

class CheckoutPaymentSuccess extends CheckoutState {
  final PaymentResult result;
  CheckoutPaymentSuccess({required this.result});
}

class CheckoutError extends CheckoutState {
  final String message;
  CheckoutError({required this.message});
}
