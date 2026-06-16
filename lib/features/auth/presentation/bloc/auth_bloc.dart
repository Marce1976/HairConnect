import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hair_connect/features/auth/data/auth_service.dart';
import 'package:hair_connect/core/di/service_locator.dart';
import 'package:hair_connect/core/errors/auth_failure.dart' as failures;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({AuthService? authService})
      : _authService = authService ?? sl<AuthService>(),
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.login(event.email, event.password);
      emit(AuthSuccess(isClient: event.isClient));
    } on failures.AuthFailure catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Error inesperado: $e'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.register(
        event.email,
        event.password,
        name: event.name,
        isClient: event.isClient,
      );
      emit(AuthSuccess(isClient: event.isClient));
    } on failures.AuthFailure catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Error inesperado: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Error en logout (no crítico): $e');
    }
    emit(AuthInitial());
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        emit(AuthSuccess(isClient: event.isClient));
      } else {
        emit(AuthInitial()); // Usuario canceló el diálogo
      }
    } on failures.AuthFailure catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Error inesperado: $e'));
    }
  }
}
