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

// Halaman Snap sudah dibuka, menunggu user menyelesaikan pembayaran di sana.
// Bloc otomatis polling status di background setelah state ini di-emit.
class CheckoutAwaitingPayment extends CheckoutState {
  final String redirectUrl;
  final String transactionId;
  CheckoutAwaitingPayment({required this.redirectUrl, required this.transactionId});
}

class CheckoutPaymentSuccess extends CheckoutState {
  final PaymentResult result;
  CheckoutPaymentSuccess({required this.result});
}

class CheckoutError extends CheckoutState {
  final String message;
  CheckoutError({required this.message});
}
