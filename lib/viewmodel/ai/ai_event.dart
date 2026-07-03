part of 'ai_bloc.dart';

abstract class AiEvent {}

// Chat
class AiChatMessageSent extends AiEvent {
  final String content;
  AiChatMessageSent({required this.content});
}

class AiChatCleared extends AiEvent {}

// Reset (dipakai trip planner untuk kembali ke form setelah error, tanpa
// meminjam semantik "chat cleared" yang sebenarnya untuk fitur lain)
class AiStateReset extends AiEvent {}

// Smart Search
class AiSmartSearchRequested extends AiEvent {
  final String query;
  AiSmartSearchRequested({required this.query});
}

// Generate Description
class AiDescriptionRequested extends AiEvent {
  final String type;
  final String name;
  final String location;
  final List<String>? amenities;
  final double? price;
  final double? rating;

  AiDescriptionRequested({
    required this.type,
    required this.name,
    required this.location,
    this.amenities,
    this.price,
    this.rating,
  });
}

// Trip Planner
class AiTripPlanRequested extends AiEvent {
  final int duration;
  final double budget;
  final List<String> interests;
  final String? startDate;
  final String? groupType;

  AiTripPlanRequested({
    required this.duration,
    required this.budget,
    required this.interests,
    this.startDate,
    this.groupType,
  });
}
