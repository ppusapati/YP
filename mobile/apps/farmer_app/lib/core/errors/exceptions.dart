/// Base exception for application-level errors.
sealed class AppException implements Exception {
  const AppException({this.message = '', this.code});

  final String message;
  final String? code;

  @override
  String toString() => '$runtimeType($code): $message';
}

/// Exception from remote server/API calls.
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error',
    super.code,
    this.statusCode,
  });

  final int? statusCode;
}

/// Exception from local cache operations.
class CacheException extends AppException {
  const CacheException({super.message = 'Cache error', super.code});
}

/// Exception due to network connectivity issues.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
  });
}

/// Exception when a requested resource is not found.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code,
  });
}

/// Exception for authentication failures.
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed',
    super.code,
  });
}

/// Exception for permission-related failures (e.g., location, camera).
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'Permission denied',
    super.code,
    required this.permissionType,
  });

  final String permissionType;
}
