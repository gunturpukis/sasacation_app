import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/data/model/explore_model.dart';
import 'package:sasacation/data/repo/explore_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;

  BookingBloc({BookingRepository? bookingRepository})
      : _bookingRepository = bookingRepository ?? BookingRepository(),
        super(BookingInitial()) {
    on<BookingListRequested>(_onListRequested);
    on<BookingCancelRequested>(_onCancelRequested);
  }

  Future<void> _onListRequested(BookingListRequested event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final bookings = await _bookingRepository.getMyBookings();
    emit(BookingListLoaded(bookings: bookings));
  }

  Future<void> _onCancelRequested(BookingCancelRequested event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await _bookingRepository.cancelBooking(event.bookingId);
    if (result['success'] == true) {
      emit(BookingCancelled(bookingId: event.bookingId));
    } else {
      emit(BookingError(message: result['message'] ?? 'Gagal membatalkan booking'));
    }
  }
}
