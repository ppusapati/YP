import 'package:equatable/equatable.dart';

/// Base failure class for domain-level error handling.
sealed class Failure extends Equatable {
  const Failure({this.message = '', this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Failure originating from a remote server or API call.
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error', super.code, this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure originating from local cache operations.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error', super.code});
}

/// Failure due to network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection', super.code});
}

/// Failure due to invalid input or validation errors.
class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation error', super.code});
}

/// Failure when a requested resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found', super.code});
}

/// Failure due to authentication or authorization issues.
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication error', super.code});
}

/// Failure due to insufficient permissions.
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied',
    super.code,
  });
}
