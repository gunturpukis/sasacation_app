part of 'auth_bloc.dart';

abstract class AuthState {}

// Initial / unknown
class AuthInitial extends AuthState {}

// Loading states
class AuthLoading extends AuthState {}

// Authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated({required this.user});
}

// Unauthenticated
class AuthUnauthenticated extends AuthState {}

// Error
class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

// Profile updated
class AuthProfileUpdated extends AuthState {
  final UserModel user;
  AuthProfileUpdated({required this.user});
}
