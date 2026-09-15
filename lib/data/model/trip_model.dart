// ─── Trip Model ─────────────────────────────────────────────────────────────
// Model for persisting user trips (AI-generated itineraries saved by user)
import 'package:sasacation/data/model/ai_model.dart';
import 'package:sasacation/utils/json_helper.dart';

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