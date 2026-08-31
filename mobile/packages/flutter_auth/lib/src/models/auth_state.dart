import 'package:equatable/equatable.dart';

import 'auth_token.dart';
import 'user_model.dart';

/// Sealed class representing the authentication state of the application.
///
/// The four possible states are:
/// - [Authenticated] — the user is logged in with a valid token.
/// - [Unauthenticated] — no user is logged in.
/// - [AuthLoading] — an auth operation (login, refresh) is in progress.
/// - [AuthError] — an authentication operation failed.
sealed class AuthState extends Equatable {
  const AuthState();
}

/// The user is authenticated and has a valid session.
class Authenticated extends AuthState {
  const Authenticated({
    required this.user,
    required this.token,
  });

  /// The currently logged-in user.
  final User user;

  /// The active authentication token.
  final AuthToken token;

  @override
  List<Object?> get props => [user, token];

  @override
  String toString() => 'Authenticated(user: ${user.name})';
}

/// No user is currently logged in.
class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'Unauthenticated';
}

/// An authentication operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'AuthLoading';
}

/// An authentication operation failed.
class AuthError extends AuthState {
  const AuthError({required this.message});

  /// A human-readable error message describing the failure.
  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthError(message: $message)';
}
