import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/notification_service.dart';
import 'package:sasacation/data/model/user_model.dart';
import 'package:sasacation/data/repo/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// AuthBloc = ViewModel for Auth
/// MVVM: View → ViewModel (AuthBloc) → Repository (AuthRepository) → API
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthAppleSignInRequested>(_onAppleSignIn);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthProfileRequested>(_onGetProfile);
    on<AuthProfileUpdateRequested>(_onUpdateProfile);
  }

  Future<void> _onCheckStatus(AuthCheckStatusRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authRepository.getProfile();
      emit(user != null ? AuthAuthenticated(user: user) : AuthUnauthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.login(email: event.email, password: event.password);
    if (result['success'] == true) {
      emit(AuthAuthenticated(user: result['user'] as UserModel));
      NotificationService.instance.initialize(registerTokenToBackend: true);
    } else {
      emit(AuthError(message: result['message'] ?? 'Login gagal'));
    }
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.register(
        name: event.name, email: event.email, password: event.password);
    if (result['success'] == true) {
      emit(AuthAuthenticated(user: result['user'] as UserModel));
      NotificationService.instance.initialize(registerTokenToBackend: true);
    } else {
      emit(AuthError(message: result['message'] ?? 'Registrasi gagal'));
    }
  }

  Future<void> _onGoogleSignIn(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithGoogle();
    if (result['success'] == true) {
      emit(AuthAuthenticated(user: result['user'] as UserModel));
      NotificationService.instance.initialize(registerTokenToBackend: true);
    } else {
      emit(AuthError(message: result['message'] ?? 'Google Sign In gagal'));
    }
  }

  Future<void> _onAppleSignIn(AuthAppleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithApple();
    if (result['success'] == true) {
      emit(AuthAuthenticated(user: result['user'] as UserModel));
      NotificationService.instance.initialize(registerTokenToBackend: true);
    } else {
      emit(AuthError(message: result['message'] ?? 'Apple Sign In gagal'));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await NotificationService.instance.unregisterToken();
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onUpdateProfile(AuthProfileUpdateRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.updateProfile(name: event.name);
    if (result['success'] == true) {
      emit(AuthProfileUpdated(user: result['user'] as UserModel));
    } else {
      // CATATAN: state AuthError menimpa data user di memory. Layar pemanggil
      // WAJIB dispatch AuthProfileRequested lagi setelah menampilkan error
      // agar state kembali ke AuthAuthenticated. (Lihat personal_info_screen.)
      emit(AuthError(message: result['message'] ?? 'Gagal memperbarui profil'));
    }
  }

  Future<void> _onGetProfile(AuthProfileRequested event, Emitter<AuthState> emit) async {
    final user = await _authRepository.getProfile();
    if (user != null) {
      emit(AuthAuthenticated(user: user));
      NotificationService.instance.initialize(registerTokenToBackend: true);
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
