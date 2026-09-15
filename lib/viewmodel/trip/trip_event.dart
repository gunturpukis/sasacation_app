// ─── Trip Events ────────────────────────────────────────────────────────────
part of 'trip_bloc.dart';

abstract class TripEvent {}

// Trip loading
class TripsLoadRequested extends TripEvent {}

// Trip saving
class TripSaveRequested extends TripEvent {
  final TripModel trip;

  TripSaveRequested({required this.trip});
}

// Trip deletion
class TripDeleteRequested extends TripEvent {
  final String tripId;

  TripDeleteRequested({required this.tripId});
}

// Trip detail loading
class TripLoadRequested extends TripEvent {
  final String tripId;

  TripLoadRequested({required this.tripId});
}

// Clear trips (for testing/logout)
class TripsClearRequested extends TripEvent {}

// Get last trip ID
class LastTripIdRequested extends TripEvent {}