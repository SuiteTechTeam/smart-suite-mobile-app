import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_repository.dart';
import '../services/auth_api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<AuthUserLoaded>(_onAuthUserLoaded);
  }
  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('AuthBloc: Starting sign in for ${event.email}...');
    emit(AuthLoading());
    try {
      final user = await _authRepository
          .signIn(event.email, event.password, event.role);
      debugPrint('AuthBloc: Sign in successful for ${user.email}');
      emit(AuthAuthenticated(user));
    } on ApiException catch (e) {
      debugPrint('AuthBloc: API Exception during sign in: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      debugPrint('AuthBloc: Unexpected error during sign in: $e');
      emit(AuthError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository
          .signUp(
            event.name,
            event.surname,
            event.phone,
            event.email,
            event.password,
            event.role,
          );
      emit(AuthSignUpSuccess());
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to sign out: $e'));
    }
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('AuthBloc: Starting auth status check...');
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      debugPrint('AuthBloc: isAuthenticated = $isAuthenticated');

      if (isAuthenticated) {
        debugPrint('AuthBloc: Getting current user...');
        final user = await _authRepository.getCurrentUser();
        debugPrint('AuthBloc: Current user = ${user?.email}');

        if (user != null) {
          debugPrint('AuthBloc: Emitting AuthAuthenticated');
          emit(AuthAuthenticated(user));
        } else {
          debugPrint('AuthBloc: User is null, emitting AuthUnauthenticated');
          emit(AuthUnauthenticated());
        }
      } else {
        debugPrint('AuthBloc: Not authenticated, emitting AuthUnauthenticated');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('AuthBloc: Error during auth status check: $e');
      // En caso de timeout o cualquier error, asumimos que no está autenticado
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthUserLoaded(
    AuthUserLoaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthAuthenticated(event.user));
  }
}
