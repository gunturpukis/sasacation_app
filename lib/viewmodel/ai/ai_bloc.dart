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
    on<AiChatHistoryRequested>(_onChatHistoryRequested);
    on<AiStateReset>((event, emit) => emit(AiInitial()));
    on<AiSmartSearchRequested>(_onSmartSearch);
    on<AiDescriptionRequested>(_onGenerateDescription);
    on<AiTripPlanRequested>(_onTripPlan);

    // Restore percakapan terakhir begitu AiBloc dibuat (app startup).
    // Untuk guest ini akan gagal-diam (lihat fetchLatestSession) dan AiBloc
    // tetap di AiInitial seperti perilaku sebelumnya — tidak ada breaking change.
    add(AiChatHistoryRequested());
  }

  Future<void> _onChatHistoryRequested(
    AiChatHistoryRequested event,
    Emitter<AiState> emit,
  ) async {
    final result = await _aiRepo.fetchLatestSession();
    final messages = result['messages'] as List<ChatMessage>;
    // Kalau tidak ada riwayat sama sekali, tetap di AiInitial (bukan
    // AiChatState kosong) supaya UI chat screen menampilkan empty-state
    // "Mulai ngobrol dengan Sasa" seperti sebelumnya, bukan bubble kosong.
    if (messages.isEmpty) return;

    emit(AiChatState(
      messages: messages,
      sessionId: result['sessionId'] as String?,
    ));
  }

  Future<void> _onChatMessage(
    AiChatMessageSent event,
    Emitter<AiState> emit,
  ) async {
    final currentState = state;
    final currentMessages =
        currentState is AiChatState ? currentState.messages : <ChatMessage>[];
    final currentSessionId =
        currentState is AiChatState ? currentState.sessionId : null;

    // Tambah pesan user ke history
    final updatedMessages = [
      ...currentMessages,
      ChatMessage.user(event.content),
    ];

    // Emit loading dengan pesan user sudah tampil, sessionId dipertahankan
    emit(AiChatState(
      messages: updatedMessages,
      isLoading: true,
      sessionId: currentSessionId,
    ));

    final result = await _aiRepo.sendMessage(
      updatedMessages,
      sessionId: currentSessionId,
    );

    if (result['success'] == true) {
      final assistantReply = ChatMessage.assistant(
        result['reply'] as String,
        tripPlan: result['tripPlan'] as TripPlan?,
      );
      emit(AiChatState(
        messages: [...updatedMessages, assistantReply],
        isLoading: false,
        // Ambil sessionId dari response — di request pertama ini yang
        // pertama kali terisi (backend baru buat sesinya di sana)
        sessionId: (result['sessionId'] as String?) ?? currentSessionId,
      ));
    } else {
      emit(AiChatState(
        messages: updatedMessages,
        isLoading: false,
        error: result['message'] as String,
        sessionId: currentSessionId,
      ));
    }
  }

  void _onChatCleared(AiChatCleared event, Emitter<AiState> emit) {
    // Catatan: ini cuma reset state LOKAL (mulai obrolan baru di layar).
    // Riwayat sesi lama TETAP ada di server (tidak dihapus) — kalau user
    // buka app lagi nanti, AiChatHistoryRequested tetap akan restore sesi
    // yang lama itu, bukan yang baru ini, sampai ada pesan baru terkirim.
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
