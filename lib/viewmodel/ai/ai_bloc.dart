import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/data/model/ai_model.dart';
import 'package:sasacation/data/repo/ai_repository.dart';

part 'ai_event.dart';
part 'ai_state.dart';

/// AiBloc = ViewModel for all AI features
/// MVVM: View → AiBloc → AiRepository → Backend → Claude API
class AiBloc extends Bloc<AiEvent, AiState> {
  final AiRepository _aiRepo;

  AiBloc({AiRepository? aiRepository})
      : _aiRepo = aiRepository ?? AiRepository(),
        super(AiInitial()) {
    on<AiChatMessageSent>(_onChatMessage);
    on<AiChatCleared>(_onChatCleared);
    on<AiStateReset>((event, emit) => emit(AiInitial()));
    on<AiSmartSearchRequested>(_onSmartSearch);
    on<AiDescriptionRequested>(_onGenerateDescription);
    on<AiTripPlanRequested>(_onTripPlan);
  }

  Future<void> _onChatMessage(
    AiChatMessageSent event,
    Emitter<AiState> emit,
  ) async {
    final currentMessages = state is AiChatState
        ? (state as AiChatState).messages
        : <ChatMessage>[];

    // Tambah pesan user ke history
    final updatedMessages = [
      ...currentMessages,
      ChatMessage.user(event.content),
    ];

    // Emit loading dengan pesan user sudah tampil
    emit(AiChatState(messages: updatedMessages, isLoading: true));

    final result = await _aiRepo.sendMessage(updatedMessages);

    if (result['success'] == true) {
      final assistantReply = ChatMessage.assistant(result['reply'] as String);
      emit(AiChatState(
        messages: [...updatedMessages, assistantReply],
        isLoading: false,
      ));
    } else {
      emit(AiChatState(
        messages: updatedMessages,
        isLoading: false,
        error: result['message'] as String,
      ));
    }
  }

  void _onChatCleared(AiChatCleared event, Emitter<AiState> emit) {
    emit(AiInitial());
  }

  Future<void> _onSmartSearch(
    AiSmartSearchRequested event,
    Emitter<AiState> emit,
  ) async {
    emit(AiSearchLoading(query: event.query));
    final result = await _aiRepo.smartSearch(event.query);
    if (result['success'] == true) {
      emit(AiSearchLoaded(
        query: event.query,
        result: result['result'] as SmartSearchResult,
      ));
    } else {
      emit(AiError(message: result['message'] as String));
    }
  }

  Future<void> _onGenerateDescription(
    AiDescriptionRequested event,
    Emitter<AiState> emit,
  ) async {
    emit(AiDescriptionLoading());
    final result = await _aiRepo.generateDescription(
      type: event.type,
      name: event.name,
      location: event.location,
      amenities: event.amenities,
      price: event.price,
      rating: event.rating,
    );
    if (result['success'] == true) {
      emit(AiDescriptionLoaded(description: result['description'] as String));
    } else {
      emit(AiError(message: result['message'] as String));
    }
  }

  Future<void> _onTripPlan(
    AiTripPlanRequested event,
    Emitter<AiState> emit,
  ) async {
    emit(AiTripPlanLoading());
    final result = await _aiRepo.generateTripPlan(
      duration: event.duration,
      budget: event.budget,
      interests: event.interests,
      startDate: event.startDate,
      groupType: event.groupType,
    );
    if (result['success'] == true) {
      emit(AiTripPlanLoaded(plan: result['plan'] as TripPlan));
    } else {
      emit(AiError(message: result['message'] as String));
    }
  }
}
