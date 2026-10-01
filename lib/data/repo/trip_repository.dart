// ─── Trip Repository ────────────────────────────────────────────────────────
// F6: penyimpanan pindah dari SharedPreferences lokal ke backend
// (`/api/itineraries`). Skema backend tidak punya field khas-AI (summary,
// estimasi biaya, tips, bestTimeToVisit, budget, interests, groupType,
// duration) — field itu disimpan sebagai OVERLAY lokal (prefs, keyed by
// server id) dan digabung saat load, sehingga layar detail/manajemen yang
// sudah ada tetap berfungsi penuh.
//
// Konsekuensi jujur: overlay hanya ada di device ini. Bila user login di
// device lain, itinerary tampil tanpa summary/biaya (netral, bukan error).
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sasacation/data/api/api_client.dart';
import 'package:sasacation/data/model/trip_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripRepository {
  static const String _extrasKey = 'trip_extras_overlay';
  static const String _lastTripIdKey = 'last_trip_id';

  // ── Overlay lokal ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _readExtras() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_extrasKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeExtras(Map<String, dynamic> extras) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_extrasKey, jsonEncode(extras));
  }

  Map<String, dynamic> _extrasOf(TripModel trip) => {
        'summary': trip.summary,
        'totalEstimatedCost': trip.totalEstimatedCost,
        'tips': trip.tips,
        'bestTimeToVisit': trip.bestTimeToVisit,
        'destination': trip.destination,
        'duration': trip.duration,
        'budget': trip.budget,
        'interests': trip.interests,
        'groupType': trip.groupType,
      };

  TripModel _withExtras(TripModel trip, Map<String, dynamic>? extra) {
    if (extra == null) return trip;
    final tips = extra['tips'];
    final interests = extra['interests'];
    return TripModel(
      id: trip.id,
      title: trip.title,
      summary: (extra['summary'] ?? '') as String,
      totalEstimatedCost:
          (extra['totalEstimatedCost'] as num?)?.toDouble() ?? 0,
      days: trip.days,
      tips: tips is List ? List<String>.from(tips) : const [],
      bestTimeToVisit: (extra['bestTimeToVisit'] ?? '') as String,
      createdAt: trip.createdAt,
      destination: extra['destination'] as String? ?? trip.destination,
      duration: (extra['duration'] as num?)?.toInt(),
      budget: (extra['budget'] as num?)?.toDouble(),
      interests:
          interests is List ? List<String>.from(interests) : const [],
      groupType: extra['groupType'] as String?,
    );
  }

  // ── CRUD backend ─────────────────────────────────────────────────────
  Future<List<TripModel>> getTrips() async {
    try {
      final res = await ApiClient.get('/itineraries/my');
      final raw = res.data['data'];
      final list = raw is List ? raw : const [];
      final extras = await _readExtras();
      final trips = list
          .whereType<Map>()
          .map((e) => TripModel.fromItineraryJson(
              Map<String, dynamic>.from(e)))
          .where((t) => t.id.isNotEmpty)
          .map((t) {
            final extra = extras[t.id];
            return _withExtras(
                t, extra is Map ? Map<String, dynamic>.from(extra) : null);
          })
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Tandai trip terakhir untuk Deep-link "lanjutkan terakhir".
      if (trips.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastTripIdKey, trips.first.id);
      }
      return trips;
    } catch (_) {
      return [];
    }
  }

  Future<TripModel> saveTrip(TripModel trip) async {
    final res = await ApiClient.post('/itineraries', data: {
      'title': trip.title,
      if (trip.destination != null && trip.destination!.isNotEmpty)
        'destination': trip.destination,
      'items': trip.toItineraryItems(),
    });
    final saved = TripModel.fromItineraryJson(
        Map<String, dynamic>.from(res.data['data'] as Map));
    // Server tidak menyimpan field khas-AI — simpan sebagai overlay lokal.
    final extras = await _readExtras();
    extras[saved.id] = _extrasOf(trip);
    await _writeExtras(extras);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTripIdKey, saved.id);
    return _withExtras(saved, _extrasOf(trip));
  }

  Future<TripModel?> getTripById(String id) async {
    try {
      final res = await ApiClient.get('/itineraries/$id');
      final trip = TripModel.fromItineraryJson(
          Map<String, dynamic>.from(res.data['data'] as Map));
      if (trip.id.isEmpty) return null;
      final extras = await _readExtras();
      final extra = extras[trip.id];
      return _withExtras(
          trip, extra is Map ? Map<String, dynamic>.from(extra) : null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Trip tidak ditemukan');
      }
      return null;
    }
  }

  Future<bool> deleteTrip(String id) async {
    try {
      await ApiClient.delete('/itineraries/$id');
    } on DioException {
      return false;
    }
    final extras = await _readExtras();
    extras.remove(id);
    await _writeExtras(extras);
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_lastTripIdKey) == id) {
      await prefs.remove(_lastTripIdKey);
    }
    return true;
  }

  /// F6: "Add to Itinerary" — tambah satu item ke itinerary tersimpan.
  Future<bool> addItem({
    required String itineraryId,
    required int day,
    required String title,
    String? time,
    String? description,
    String? location,
    String kind = 'activity',
  }) async {
    try {
      await ApiClient.post('/itineraries/$itineraryId/items', data: {
        'day': day,
        'title': title,
        if (time != null) 'time': time,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        'kind': kind,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Helper lokal (dipertahankan untuk kompatibilitas bloc) ───────────
  Future<String?> getLastTripId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastTripIdKey);
  }

  /// Tidak ada endpoint hapus-massal — dipertahankan sebagai no-op lokal
  /// (hanya membersihkan cache device) agar event bloc lama tetap valid.
  Future<void> clearAllTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_extrasKey);
    await prefs.remove(_lastTripIdKey);
  }

  Future<int> getTripCount() async {
    final trips = await getTrips();
    return trips.length;
  }
}
