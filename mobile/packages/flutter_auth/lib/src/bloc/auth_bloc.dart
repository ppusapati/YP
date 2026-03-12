import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/auth_state.dart';
import '../models/auth_token.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

/// Base class for authentication events.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Requests a login with email and password credentials.
class LoginRequested extends AuthEvent {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Requests a logout, clearing the current session.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Requests a token refresh using the stored refresh token.
class TokenRefreshRequested extends AuthEvent {
  const TokenRefreshRequested();
}

/// Requests a check of the current authentication state (e.g., at app start).
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

/// Authentication BLoC that manages the auth lifecycle.
///
/// Handles login, logout, token refresh, and session restoration.
/// Emits [AuthState] variants to drive the UI.
///
/// Usage:
/// ```dart
/// final authBloc = AuthBloc(authRepository: authRepository);
/// authBloc.add(const AuthCheckRequested());
///
/// // In a BlocBuilder:
/// BlocBuilder<AuthBloc, AuthState>(
///   builder: (context, state) => switch (state) {
///     Authenticated(:final user) => HomeScreen(user: user),
///     Unauthenticated() => LoginScreen(),
///     AuthLoading() => LoadingScreen(),
///     AuthError(:final message) => ErrorScreen(message: message),
///   },
/// );
/// ```
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.authRepository,
  }) : super(const AuthLoading()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<TokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  /// The auth repository for performing auth operations.
  final AuthRepository authRepository;

  static final _log = Logger('AuthBloc');

  /// Timer for proactive token refresh.
  Timer? _refreshTimer;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      emit(Authenticated(user: result.user, token: result.token));
      _scheduleTokenRefresh(result.token);
      _log.info('Login successful for: ${event.email}');
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
      _log.warning('Login failed: ${e.message}');
    } on Exception catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: $e'));
      _log.severe('Unexpected login error: $e');
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _cancelRefreshTimer();

    try {
      await authRepository.logout();
    } on Exception catch (e) {
      _log.warning('Logout error (non-critical): $e');
    }

    emit(const Unauthenticated());
    _log.info('User logged out');
  }

  Future<void> _onTokenRefreshRequested(
    TokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! Authenticated) {
      _log.warning('Token refresh requested but user is not authenticated');
      return;
    }

    try {
      final newToken = await authRepository.refreshToken();
      final user = await authRepository.getCurrentUser();

      if (user != null) {
        emit(Authenticated(user: user, token: newToken));
        _scheduleTokenRefresh(newToken);
        _log.info('Token refresh successful');
      } else {
        emit(const Unauthenticated());
        _log.warning('Token refresh succeeded but user fetch failed');
      }
    } on AuthException catch (e) {
      _cancelRefreshTimer();
      emit(const Unauthenticated());
      _log.warning('Token refresh failed: ${e.message}');
    } on Exception catch (e) {
      _log.severe('Unexpected token refresh error: $e');
      // Keep the current state — the token may still be valid.
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final hasSession = await authRepository.hasActiveSession();

      if (!hasSession) {
        emit(const Unauthenticated());
        return;
      }

      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(const Unauthenticated());
        return;
      }

      final token = await authRepository.tokenService.getToken();
      if (token == null) {
        emit(const Unauthenticated());
        return;
      }

      emit(Authenticated(user: user, token: token));
      _scheduleTokenRefresh(token);
      _log.info('Auth check: session restored for ${user.email}');
    } on Exception catch (e) {
      _log.severe('Auth check error: $e');
      emit(const Unauthenticated());
    }
  }

  /// Schedules a proactive token refresh before the token expires.
  ///
  /// Refreshes 2 minutes before expiry, or immediately if already
  /// within that window.
  void _scheduleTokenRefresh(AuthToken token) {
    _cancelRefreshTimer();

    final timeUntilExpiry = token.expiresAt.difference(DateTime.now());
    // Refresh 2 minutes before expiry.
    final refreshIn = timeUntilExpiry - const Duration(minutes: 2);

    if (refreshIn.isNegative) {
      // Token is already expiring soon — refresh now.
      add(const TokenRefreshRequested());
      return;
    }

    _refreshTimer = Timer(refreshIn, () {
      add(const TokenRefreshRequested());
    });

    _log.fine('Token refresh scheduled in ${refreshIn.inMinutes} minutes');
  }

  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  Future<void> close() {
    _cancelRefreshTimer();
    return super.close();
  }
}
