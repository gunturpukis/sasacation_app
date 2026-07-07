import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/data/model/checkout_model.dart';
import 'package:sasacation/data/repo/checkout_repository.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutRepository _repo;

  CheckoutBloc({CheckoutRepository? repo})
      : _repo = repo ?? CheckoutRepository(),
        super(CheckoutInitial()) {
    on<CheckoutInitiated>(_onInitiated);
    on<CheckoutPaymentMethodSelected>(_onMethodSelected);
    on<CheckoutPaymentConfirmed>(_onPaymentConfirmed);
    on<CheckoutReset>(_onReset);
  }

  Future<void> _onInitiated(CheckoutInitiated event, Emitter<CheckoutState> emit) async {
    emit(CheckoutLoading());
    final result = await _repo.initiateCheckout(
      hotelId: event.hotelId,
      checkIn: event.checkIn,
      checkOut: event.checkOut,
      guestCount: event.guestCount,
      notes: event.notes,
    );
    if (result['success'] == true) {
      emit(CheckoutSessionLoaded(
        session: result['session'] as CheckoutSession,
        selectedMethod: null,
      ));
    } else {
      emit(CheckoutError(message: result['message'] as String));
    }
  }

  void _onMethodSelected(CheckoutPaymentMethodSelected event, Emitter<CheckoutState> emit) {
    if (state is CheckoutSessionLoaded) {
      final current = state as CheckoutSessionLoaded;
      emit(CheckoutSessionLoaded(
        session: current.session,
        selectedMethod: event.method,
      ));
    }
  }

  Future<void> _onPaymentConfirmed(CheckoutPaymentConfirmed event, Emitter<CheckoutState> emit) async {
    if (state is! CheckoutSessionLoaded) return;
    final current = state as CheckoutSessionLoaded;
    if (current.selectedMethod == null) return;

    emit(CheckoutPaymentProcessing());

    final session = current.session;
    // FIX: kirim SEMUA detail booking yang backend butuhkan, diambil dari
    // session yang sudah kita simpan sejak initiateCheckout — bukan cuma
    // sessionId + paymentMethod seperti sebelumnya. Backend PostgreSQL
    // versi ini stateless, jadi tidak bisa "mengingat" sesi dari initiate.
    final result = await _repo.processPayment(
      hotelId: session.hotel['id'] as String,
      checkIn: session.checkIn,
      checkOut: session.checkOut,
      nights: session.nights,
      guestCount: session.guestCount,
      notes: session.notes,
      totalAmount: session.pricing.total,
      paymentMethod: current.selectedMethod!.id,
    );

    if (result['success'] == true) {
      emit(CheckoutPaymentSuccess(result: result['result'] as PaymentResult));
    } else {
      emit(CheckoutError(message: result['message'] as String));
    }
  }

  void _onReset(CheckoutReset event, Emitter<CheckoutState> emit) {
    emit(CheckoutInitial());
  }
}
