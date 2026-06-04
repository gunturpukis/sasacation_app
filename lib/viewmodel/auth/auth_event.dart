part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  AuthRegisterRequested({required this.name, required this.email, required this.password});
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthAppleSignInRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthProfileRequested extends AuthEvent {}

class AuthCheckStatusRequested extends AuthEvent {}
