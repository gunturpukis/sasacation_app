// ─── Trip Repository ────────────────────────────────────────────────────────
// Handles persistence of user trips (AI-generated itineraries saved by user)
// Currently uses shared_preferences for local storage
// Designed to be easily swapped with backend implementation later
import 'dart:convert';

import 'package:sasacation/data/model/trip_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripRepository {
  static const String _tripsKey = 'saved_trips';
  static const String _lastTripIdKey = 'last_trip_id';

  // Get all saved trips
  Future<List<TripModel>> getTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = prefs.getStringList(_tripsKey) ?? [];

    return tripsJson
        .map((json) => TripModel.fromJson(jsonDecode(json)))
        .where((trip) => trip.id.isNotEmpty) // Filter out invalid trips
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
  }

  // Save a trip
  Future<TripModel> saveTrip(TripModel trip) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing trips
    final trips = await getTrips();

    // Remove if updating existing trip (by ID)
    final existingIndex = trips.indexWhere((t) => t.id == trip.id);
    if (existingIndex != -1) {
      trips.removeAt(existingIndex);
    }

    // Add/update trip
    trips.add(trip);

    // Save back to preferences
    final tripsJson = trips
        .map((trip) => jsonEncode(trip.toJson()))
        .toList();
    await prefs.setStringList(_tripsKey, tripsJson);

    // Update last trip ID
    await prefs.setString(_lastTripIdKey, trip.id);

    return trip;
  }

  // Get a trip by ID
  Future<TripModel?> getTripById(String id) async {
    final trips = await getTrips();
    return trips.firstWhere((trip) => trip.id == id, orElse: () => throw Exception('Trip not found'));
  }

  // Delete a trip by ID
  Future<bool> deleteTrip(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final trips = await getTrips();

    final initialLength = trips.length;
    trips.removeWhere((trip) => trip.id == id);

    if (trips.length < initialLength) {
      // Actually removed something
      final tripsJson = trips
          .map((trip) => jsonEncode(trip.toJson()))
          .toList();
      await prefs.setStringList(_tripsKey, tripsJson);

      // Update last trip ID if we deleted the last one
      final lastId = prefs.getString(_lastTripIdKey);
      if (lastId == id) {
        if (trips.isNotEmpty) {
          await prefs.setString(_lastTripIdKey, trips.first.id);
        } else {
          await prefs.remove(_lastTripIdKey);
        }
      }

      return true;
    }

    return false;
  }

  // Get the most recently saved trip ID
  Future<String?> getLastTripId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastTripIdKey);
  }

  // Clear all trips (useful for testing/logout)
  Future<void> clearAllTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripsKey);
    await prefs.remove(_lastTripIdKey);
  }

  // Get trip count
  Future<int> getTripCount() async {
    final trips = await getTrips();
    return trips.length;
  }
}