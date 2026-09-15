// ─── Trip States ────────────────────────────────────────────────────────────
part of 'trip_bloc.dart';

abstract class TripState {}

class TripInitial extends TripState {}

// Loading states
class TripsLoading extends TripState {}
class TripSaving extends TripState {}
class TripDeleting extends TripState {}
class TripLoading extends TripState {}

// Loaded states
class TripsLoaded extends TripState {
  final List<TripModel> trips;

  TripsLoaded({required this.trips});
}

class TripSaved extends TripState {
  final TripModel trip;

  TripSaved({required this.trip});
}

class TripDeleted extends TripState {
  final String tripId;

  TripDeleted({required this.tripId});
}

class TripLoaded extends TripState {
  final TripModel trip;

  TripLoaded({required this.trip});
}

// Error state
class TripError extends TripState {
  final String message;

  TripError({required this.message});
}

// Last trip ID
class LastTripIdLoaded extends TripState {
  final String? tripId;

  LastTripIdLoaded({required this.tripId});
}