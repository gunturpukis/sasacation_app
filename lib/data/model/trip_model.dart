// ─── Trip Model ─────────────────────────────────────────────────────────────
// Model for persisting user trips (AI-generated itineraries saved by user)
//
// F6: penyimpanan pindah dari SharedPreferences lokal ke backend
// (`/api/itineraries`). Skema backend lebih datar (items per hari, tanpa
// biaya/tips), jadi field khas-AI (summary, costs, tips, dst) disimpan
// sebagai overlay lokal keyed by server id (lihat TripRepository) — layar
// yang sudah ada tetap berfungsi penuh tanpa perubahan.
import 'package:sasacation/data/model/ai_model.dart';
import 'package:sasacation/utils/json_helper.dart';

/// Petakan tipe aktivitas AI (bebas, hasil generate) ke kind backend
/// (activity|meal|rest|transport|stay). Tak dikenal → activity.
String tripKindForActivity(String type) {
  final t = type.toLowerCase();
  if (t.contains('meal') ||
      t.contains('food') ||
      t.contains('eat') ||
      t.contains('restaurant') ||
      t.contains('lunch') ||
      t.contains('dinner') ||
      t.contains('breakfast') ||
      t.contains('kuliner') ||
      t.contains('seafood')) {
    return 'meal';
  }
  if (t.contains('stay') ||
      t.contains('hotel') ||
      t.contains('villa') ||
      t.contains('check-in') ||
      t.contains('checkin') ||
      t.contains('resort')) {
    return 'stay';
  }
  if (t.contains('transport') ||
      t.contains('car') ||
      t.contains('flight') ||
      t.contains('boat') ||
      t.contains('transfer') ||
      t.contains('drive')) {
    return 'transport';
  }
  if (t.contains('rest') ||
      t.contains('break') ||
      t.contains('relax') ||
      t.contains('yoga') ||
      t.contains('spa') ||
      t.contains('istirahat')) {
    return 'rest';
  }
  return 'activity';
}

class TripModel {
  final String id;
  final String title;
  final String summary;
  final double totalEstimatedCost;
  final List<TripDay> days;
  final List<String> tips;
  final String bestTimeToVisit;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? destination; // Denormalized for easy querying/display
  final int? duration; // Denormalized for easy querying/display
  final double? budget; // Denormalized for easy querying/display
  final List<String>? interests; // Denormalized for easy querying/display
  final String? groupType; // Denormalized for easy querying/display

  const TripModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.totalEstimatedCost,
    required this.days,
    required this.tips,
    required this.bestTimeToVisit,
    required this.createdAt,
    this.updatedAt,
    this.destination,
    this.duration,
    this.budget,
    this.interests,
    this.groupType,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        summary: json['summary'] ?? '',
        totalEstimatedCost: parseDouble(json['totalEstimatedCost']),
        days: (json['days'] as List? ?? [])
            .map((d) => TripDay.fromJson(d))
            .toList(),
        tips: List<String>.from(json['tips'] ?? []),
        bestTimeToVisit: json['bestTimeToVisit'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        destination: json['destination'],
        duration: json['duration'] as int?,
        budget: parseDouble(json['budget']),
        interests: List<String>.from(json['interests'] ?? []),
        groupType: json['groupType'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'totalEstimatedCost': totalEstimatedCost,
        'days': days.map((d) => d.toJson()).toList(),
        'tips': tips,
        'bestTimeToVisit': bestTimeToVisit,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'destination': destination,
        'duration': duration,
        'budget': budget,
        'interests': interests,
        'groupType': groupType,
      };

  /// Bangun dari JSON itinerary backend (GET /itineraries/my atau /:id).
  /// Field khas-AI yang tak ada di skema backend diisi default/netral lalu
  /// digabung overlay lokal oleh TripRepository — JANGAN pakai factory ini
  /// langsung bila butuh summary/biaya (pakai repository).
  factory TripModel.fromItineraryJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.whereType<Map>().toList()
        : <Map>[];
    final byDay = <int, List<Map<String, dynamic>>>{};
    for (final raw in items) {
      final item = Map<String, dynamic>.from(raw);
      final day = parseInt(item['day'], 1);
      byDay.putIfAbsent(day, () => []).add(item);
    }
    final days = byDay.entries.map((e) {
      final acts = e.value.map((item) {
        final kind = (item['kind'] ?? 'activity').toString();
        return TripActivity(
          time: (item['time'] ?? '').toString(),
          name: (item['title'] ?? '').toString(),
          type: kind,
          location: (item['location'] ?? '').toString(),
          duration: '',
          estimatedCost: 0,
          notes: (item['description'] ?? '').toString(),
          itemId: (item['id'] ?? '').toString(),
        );
      }).toList();
      return TripDay(
        day: e.key,
        title: 'Day ${e.key}',
        activities: acts,
        dailyCost: 0,
      );
    }).toList()
      ..sort((a, b) => a.day.compareTo(b.day));

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'].toString());
    } catch (_) {
      createdAt = DateTime.now();
    }
    return TripModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: '',
      totalEstimatedCost: 0,
      days: days,
      tips: const [],
      bestTimeToVisit: '',
      createdAt: createdAt,
      destination: json['destination']?.toString(),
    );
  }

  /// Flatten hari-hari AI menjadi items backend
  /// ({day, time?, title, description?, location?, kind}).
  List<Map<String, dynamic>> toItineraryItems() => [
        for (final day in days)
          for (final a in day.activities)
            {
              'day': day.day,
              if (a.time.isNotEmpty) 'time': a.time,
              'title': a.name,
              if (a.notes.isNotEmpty) 'description': a.notes,
              if (a.location.isNotEmpty) 'location': a.location,
              'kind': tripKindForActivity(a.type),
            },
      ];

  // Create a TripModel from a TripPlan (for saving AI-generated plans)
  factory TripModel.fromTripPlan({
    required TripPlan plan,
    required String destination,
    required int duration,
    required double budget,
    required List<String> interests,
    required String? groupType,
  }) {
    return TripModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID generation
      title: plan.title,
      summary: plan.summary,
      totalEstimatedCost: plan.totalEstimatedCost,
      days: plan.days,
      tips: plan.tips,
      bestTimeToVisit: plan.bestTimeToVisit,
      createdAt: DateTime.now(),
      destination: destination,
      duration: duration,
      budget: budget,
      interests: interests,
      groupType: groupType,
    );
  }
}