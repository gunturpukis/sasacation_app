part of 'ai_bloc.dart';

abstract class AiState {}

class AiInitial extends AiState {}

class AiError extends AiState {
  final String message;
  AiError({required this.message});
}

// Chat states
class AiChatState extends AiState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  // Sesi chat yang sedang berjalan di server. null berarti: guest, atau
  // belum ada pesan terkirim sama sekali di sesi ini (akan dibuat backend
  // pada request pertama).
  final String? sessionId;

  AiChatState({
    required this.messages,
    this.isLoading = false,
    this.error,
    this.sessionId,
  });
}

// Smart Search states
class AiSearchLoading extends AiState {
  final String query;
  AiSearchLoading({required this.query});
}

class AiSearchLoaded extends AiState {
  final String query;
  final SmartSearchResult result;
  AiSearchLoaded({required this.query, required this.result});
}

// Description states
class AiDescriptionLoading extends AiState {}

class AiDescriptionLoaded extends AiState {
  final String description;
  AiDescriptionLoaded({required this.description});
}

// Trip Plan states
class AiTripPlanLoading extends AiState {}

class AiTripPlanLoaded extends AiState {
  final TripPlan plan;
  AiTripPlanLoaded({required this.plan});
}
