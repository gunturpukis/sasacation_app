import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/data/model/checkout_model.dart';
import 'package:sasacation/data/repo/checkout_repository.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutRepository _repo;

  // Parameter booking asli, disimpan dari CheckoutInitiated supaya bisa
  // dipakai lagi saat _onPaymentConfirmed — backend /checkout/pay stateless,
  // tidak mengenal sessionId, jadi kita harus kirim ulang data lengkapnya.
  String? _hotelId;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int? _guestCount;
  String? _notes;

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
    _hotelId = event.hotelId;
    _checkIn = event.checkIn;
    _checkOut = event.checkOut;
    _guestCount = event.guestCount;
    _notes = event.notes;

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
    if (_hotelId == null || _checkIn == null || _checkOut == null || _guestCount == null) return;

    emit(CheckoutPaymentProcessing());
    final result = await _repo.processPayment(
      hotelId: _hotelId!,
      checkIn: _checkIn!,
      checkOut: _checkOut!,
      guestCount: _guestCount!,
      notes: _notes,
      paymentMethod: current.selectedMethod!.id,
    );

    if (result['success'] != true) {
      emit(CheckoutError(message: result['message'] as String));
      return;
    }

    final initiated = result['initiated'] as CheckoutPaymentInitiated;
    emit(CheckoutAwaitingPayment(
      redirectUrl: initiated.redirectUrl,
      transactionId: initiated.transactionId,
    ));

    // Polling otomatis: cek status tiap 3 detik, maksimal 40x (~2 menit).
    // Webhook Midtrans biasanya masuk dalam hitungan detik setelah user
    // menyelesaikan pembayaran di halaman Snap, tapi kasih ruang toleransi
    // untuk jaringan lambat.
    const maxAttempts = 40;
    const pollInterval = Duration(seconds: 3);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(pollInterval);
      if (emit.isDone) return; // widget sudah pindah/dispose, hentikan polling

      final statusResult = await _repo.checkPaymentStatus(initiated.transactionId);
      if (statusResult['success'] != true) continue; // network hiccup, coba lagi di iterasi berikutnya

      final status = statusResult['status'] as String;
      if (status == 'success') {
        emit(CheckoutPaymentSuccess(result: statusResult['result'] as PaymentResult));
        return;
      }
      if (status == 'failed') {
        emit(CheckoutError(message: 'Pembayaran gagal atau dibatalkan. Silakan coba lagi.'));
        return;
      }
      // status == 'pending' -> lanjut polling
    }

    // Timeout menunggu—BUKAN berarti gagal, webhook mungkin cuma telat.
    // Arahkan user cek My Bookings alih-alih menampilkan error yang
    // menyesatkan (uangnya bisa saja sudah terpotong).
    emit(CheckoutError(
      message: 'Belum ada konfirmasi pembayaran. Kalau Anda sudah membayar, '
          'cek status booking di halaman "My Bookings" dalam beberapa saat.',
    ));
  }

  void _onReset(CheckoutReset event, Emitter<CheckoutState> emit) {
    emit(CheckoutInitial());
  }
}
