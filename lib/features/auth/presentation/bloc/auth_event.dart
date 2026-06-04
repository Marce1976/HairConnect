part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool isClient;

  LoginRequested({
    required this.email,
    required this.password,
    required this.isClient,
  });
}

final class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final bool isClient;

  RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.isClient,
  });
}

final class LogoutRequested extends AuthEvent {}

final class GoogleSignInRequested extends AuthEvent {
  final bool isClient;

  GoogleSignInRequested({required this.isClient});
}
