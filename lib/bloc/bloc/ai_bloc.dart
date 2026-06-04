import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'ai_event.dart';
part 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  AiBloc() : super(AiInitial()) {
    on<AiEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
