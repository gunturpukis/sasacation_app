import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/data/repo/recommendation_repository.dart';

sealed class RecommendationState {}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final List<HotelModel> hotels;
  RecommendationLoaded(this.hotels);
}

class RecommendationError extends RecommendationState {
  final String message;
  RecommendationError(this.message);
}

/// ViewModel: RecommendationCubit
/// Dipakai di Home untuk section "Recommended for you". Gagal fetch TIDAK
/// ditampilkan sebagai error mencolok ke user — cukup section-nya tidak
/// tampil (lihat penggunaannya di home_page.dart), karena ini fitur
/// pelengkap, bukan fitur inti yang harus mengganggu pengalaman kalau gagal.
class RecommendationCubit extends Cubit<RecommendationState> {
  final RecommendationRepository _repo;

  RecommendationCubit({RecommendationRepository? repository})
      : _repo = repository ?? RecommendationRepository(),
        super(RecommendationInitial()) {
    load();
  }

  Future<void> load() async {
    emit(RecommendationLoading());
    try {
      final hotels = await _repo.getRecommendations();
      emit(RecommendationLoaded(hotels));
    } catch (e) {
      emit(RecommendationError(e.toString()));
    }
  }
}
