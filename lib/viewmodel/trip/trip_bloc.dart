import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/data/model/trip_model.dart';
import 'package:sasacation/data/repo/trip_repository.dart';
part 'trip_event.dart';
part 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository _tripRepository;

  TripBloc({TripRepository? tripRepository})
      : _tripRepository = tripRepository ?? TripRepository(),
        super(TripInitial()) {
    on<TripsLoadRequested>(_onTripsLoadRequested);
    on<TripSaveRequested>(_onTripSaveRequested);
    on<TripDeleteRequested>(_onTripDeleteRequested);
    on<TripLoadRequested>(_onTripLoadRequested);
    on<TripsClearRequested>(_onTripsClearRequested);
    on<LastTripIdRequested>(_onLastTripIdRequested);
  }

  Future<void> _onTripsLoadRequested(
      TripsLoadRequested event,
      Emitter<TripState> emit,
      ) async {
    emit(TripsLoading());
    try {
      final trips = await _tripRepository.getTrips();
      emit(TripsLoaded(trips: trips));
    } catch (e) {
      emit(TripError(message: 'Failed to load trips: $e'));
    }
  }

  Future<void> _onTripSaveRequested(
      TripSaveRequested event,
      Emitter<TripState> emit,
      ) async {
    emit(TripSaving());
    try {
      // F6: pakai hasil server (id asli) — bukan objek lokal, agar layar
      // detail berikutnya membuka id yang benar di backend.
      final saved = await _tripRepository.saveTrip(event.trip);
      emit(TripSaved(trip: saved));
    } catch (e) {
      emit(TripError(message: 'Failed to save trip: $e'));
    }
  }

  Future<void> _onTripDeleteRequested(
      TripDeleteRequested event,
      Emitter<TripState> emit,
      ) async {
    emit(TripDeleting());
    try {
      await _tripRepository.deleteTrip(event.tripId);
      emit(TripDeleted(tripId: event.tripId));
    } catch (e) {
      emit(TripError(message: 'Failed to delete trip: $e'));
    }
  }

  Future<void> _onTripLoadRequested(
      TripLoadRequested event,
      Emitter<TripState> emit,
      ) async {
    emit(TripLoading());
    try {
      final trip = await _tripRepository.getTripById(event.tripId);
      if (trip != null) {
        emit(TripLoaded(trip: trip));
      } else {
        emit(TripError(message: 'Trip tidak ditemukan'));
      }
    } catch (e) {
      emit(TripError(message: 'Failed to load trip: $e'));
    }
  }

  Future<void> _onTripsClearRequested(
      TripsClearRequested event,
      Emitter<TripState> emit,
      ) async {
    emit(TripsLoading());
    try {
      await _tripRepository.clearAllTrips();
      emit(TripsLoaded(trips: []));
    } catch (e) {
      emit(TripError(message: 'Failed to clear trips: $e'));
    }
  }

  Future<void> _onLastTripIdRequested(
      LastTripIdRequested event,
      Emitter<TripState> emit,
      ) async {
    try {
      final lastId = await _tripRepository.getLastTripId();
      emit(LastTripIdLoaded(tripId: lastId));
    } catch (e) {
      emit(TripError(message: 'Failed to get last trip ID: $e'));
    }
  }
}