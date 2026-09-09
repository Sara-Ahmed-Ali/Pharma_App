import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<UpdateProfileRequested>(_onUpdateProfile);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final cachedUser = await _authRepository.getCachedUser();
    if (cachedUser == null) {
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final freshUser = await _authRepository.getCurrentUser();
      emit(AuthAuthenticated(freshUser));
    } catch (e) {
      // Offline or token expired without a usable refresh token:
      // fall back to the cached profile so the app stays usable.
      emit(AuthAuthenticated(cachedUser));
    }
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_messageOf(e)));
    }
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      // Registration does not auto-login: clear any tokens stored by the
      // register call and send the user to the login screen.
      await _authRepository.logout();
      emit(RegistrationSucceeded());
    } catch (e) {
      emit(AuthError(_messageOf(e)));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.updateProfile(
        name: event.name,
        email: event.email,
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(ProfileUpdated(user));
    } catch (e) {
      emit(AuthError(_messageOf(e)));
    }
  }

  String _messageOf(Object error) {
    if (error is Failure) return error.message;
    if (error is AppException) return error.message;
    return 'An unexpected error occurred.';
  }
}